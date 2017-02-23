class IntegrationsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:accept_payload]
  skip_before_action :authenticate_user!, only: [:accept_payload]

  before_action :set_project, except: [:accept_payload]
  before_action :set_integration,    only: [:show, :edit, :update, :destroy, :new_import, :start_import]
  before_action :set_payload_integration,    only: [:accept_payload]

  load_and_authorize_resource :project
  load_and_authorize_resource :integration, :through => :project, :except => [:accept_payload]


  def index
    @integrations = @project.integrations.all
  end

  def new
    @integration = Integration.new
  end

  def create
    # STI and form_for
    # http://stackoverflow.com/questions/4507149/best-practices-to-handle-routes-for-sti-subclasses-in-rails
    # https://devblast.com/b/single-table-inheritance-with-rails-4-part-3
    @integration = (params[:name] + 'Integration').titleize.constantize.new(integration_params)

    if @integration.save
      # TODO: Redirect to details page for further instructions and editing.
      # Wo have routes only for integrations
      redirect_to integrations_project_path(@project), notice: 'Integration added.'
    else
      redirect_back fallback_location: integrations_project_path(@project), notice: @integration.errors.full_messages
    end
  end

  def accept_payload
    # HEAD request is used trello for handshaking in confirmation of webhook
    if request.head?
      head(:ok)
    elsif request.headers['X-Hook-Secret'].present? # Asana hanshake
      options = {}
      # asana wants OK (200) response along with secret in head
      options['X-Hook-Secret'] = request.headers['X-Hook-Secret'] if @integration.name == 'asana'
      head(:ok, options)
    else # save this payload
      @integration.payloads.create(info: params, event: get_event_from_headers)
      head(:ok)
    end
  end

  def edit
  end

  def update
    if @integration.update(integration_params)
      redirect_to [@project, Integration], notice: 'Updated'
    else
      render :edit
    end
  end

  def show
    session['jira_integration_id'] = @integration.id if @integration.name == 'jira'
  end

  def destroy
    @integration.destroy
    redirect_back fallback_location: project_integrations_path(@project), notice: 'Integration deleted.'
  end

  # For now keeping these import related methods here, we'll consider making a new controller
  def new_import
    @projects = @integration.project_list
  end

  def start_import
    @integration.performer = current_user
    @integration.import!(params[:external_project_id])
    redirect_to project_stories_path(@project), notice: 'Success'
  end

  def instructions
    @integration = Integration.new
    render params[:name]
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_payload_integration
    @integration = Integration.find(params[:integration_id])
  end

  def set_integration
    @integration = @project.integrations.find(params[:id])
  end

  def integration_params
    params.require(:integration).permit(:url, :title).merge(project: @project)
  end

  # def set_import_client
  #   @import_integration = ImportIntegration.build(@integration)
  # end

  def get_event_from_headers
    case @integration.name
      when 'github'
        request.headers['X-GitHub-Event']
      when 'bitbucket'
        request.headers['HTTP_X_EVENT_KEY'].split(':')[1]
      when 'trello'
        request.params['webhook']['action']['type']
      when 'jira'
        request.params['webhookEvent']
      else
        nil # Will not save this webhook
    end
  end
end

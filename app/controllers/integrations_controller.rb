class IntegrationsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:accept_payload]
  skip_before_action :authenticate_user!, only: [:accept_payload]

  before_action :set_project
  before_action :set_integration, only: [:show, :edit, :update, :destroy, :new_import, :start_import, :accept_payload]

  authorize_resource :project, except: [:accept_payload]
  authorize_resource :integration, :through => :project, :except => [:accept_payload]


  def index
    @integrations = @project.integrations
  end

  def new
    # TODO: Add information for each integration
    @integration = Integration.new
    @integrations = integration_class.where(project: @project)
  end

  def create
    # STI and form_for
    # http://stackoverflow.com/questions/4507149/best-practices-to-handle-routes-for-sti-subclasses-in-rails
    # https://devblast.com/b/single-table-inheritance-with-rails-4-part-3
    @integration = integration_class.new(project: @project)

    if @integration.save
      redirect_to edit_project_integration_path(@project, @integration)
    else
      redirect_back fallback_location: project_integrations_path(@project), notice: @integration.errors.full_messages
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
    render @integration.name
  end

  def update

    if @integration.update(integration_params)
      redirect_to list_project_integrations_path(@project, name: @integration.name), notice: 'Updated'
    else
      render :edit
    end
  end

  # TODO delete after moving all logic to specific integration page
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

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_integration
    @integration = @project.integrations.find_by_secure_id(params[:secure_id])
  end

  def integration_class
    Integration.get_class(params[:name])
  end

  def integration_params
    params.require(:integration).permit(:url, :title, :active).merge(project: @project)
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
      when 'gitlab'
        request.params['object_kind']
      when 'trello'
        request.params['webhook']['action']['type']
      when 'jira'
        request.params['webhookEvent']
      else
        nil # Will not save this webhook
    end
  end
end

class IntegrationsController < ApplicationController
  before_action :set_project
  before_action :set_integration,    only: [:show, :edit, :update, :destroy, :new_import, :start_import]
  before_action :set_import_service,  only: [:new_import, :start_import]

  load_and_authorize_resource :project
  load_and_authorize_resource :integration, :through => :project


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
    # TODO: Make it generic. For now just supporting Slack
    @integration = SlackIntegration.new(integration_params)

    if @integration.save
      # Wo have routes only for integrations
      redirect_to integrations_project_path(@project), notice: 'Integration added.'
    else
      redirect_back fallback_location: integrations_project_path(@project), notice: @integration.errors.full_messages
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
    @projects = @import_service.project_list
  end

  def start_import
    @import_service.import!(params[:external_project_id])
    redirect_to project_stories_path(@project), notice: 'Success'
  end

  def instructions
    integration_name = params[:name]

    @integration = Integration.new
    @integration.name = integration_name

    # TODO: Uncomment, after creating pages for other integrations
    # case integration_name
    #   when 'slack'
    #     render 'slack'
    #   else
    #     redirect_back fallback_location: new_project_integration_path(@project), notice: 'No instructions available'
    # end

    render 'slack'
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_integration
    @integration = @project.integrations.find(params[:id])
  end

  def integration_params
    params.require(:integration).permit(:url,:title).merge(project: @project)
  end

  def set_import_service
    @import_service = ImportService.build(@integration)
  end
end

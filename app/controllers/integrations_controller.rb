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
    @integration = Integration.new(integration_params)
    if @integration.save
      redirect_to [@project, @integration], notice: 'Done from our side. Please follow the given instructions.'
    else
      render :new
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
    redirect_to project_tasks_path(@project), notice: 'Success'
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_integration
    @integration = @project.integrations.find(params[:id])
  end

  def integration_params
    params.require(:integration).permit(:url,:name).merge(project: @project)
  end

  def set_import_service
    @import_service = ImportService.build(@integration)
  end
end

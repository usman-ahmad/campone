class IntegrationsController < ApplicationController
  before_action :set_project
  before_action :set_integration,    only: [:show, :edit, :update, :destroy]

  def index
    @integrations = Integration.all
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
  end

  def destroy
    @integration.destroy
    redirect_to project_integrations_path(@project), notice: 'Integration deleted.'
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_integration
    @integration = @project.integrations.find(params[:id])
  end

  def integration_params
    params.require(:integration).permit(:url,:vcs_name).merge(project: @project)
  end
end

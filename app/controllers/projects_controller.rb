class ProjectsController < ApplicationController
  load_and_authorize_resource
  before_action :set_project, only: [:show, :edit, :update, :destroy, :settings, :contributors, :integrations]

  # GET /projects
  # GET /projects.json
  def index
    @projects = current_user.contributions.order('position').map(&:project)
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    redirect_to project_stories_path(@project)
    # @contribution = Contribution.new
    # @contributions = @project.contributions
    #
    # @integration = Integration.new
    # @integrations = @project.integrations.all
  end

  def settings
  end

  def contributors
    @contribution = Contribution.new
    @contributions = @project.contributions
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params.merge(owner: current_user))

    respond_to do |format|
      if @project.save
        format.html { redirect_to projects_path, notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to settings_project_path(@project), notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy

    respond_to do |format|
      format.html do
        if @project.title == params[:confirm_project]
          @project.destroy
          redirect_to projects_url, notice: 'Project was successfully destroyed.'
        else
          redirect_back(fallback_location: project_path(@project), notice: 'Project verification failed.')
        end
      end

      format.json { head :no_content }
    end
  end

  def sort
    params[:project].each_with_index do |id, index|
      Contribution.find_by(project_id: id, user: current_user).update_attributes(position: index+1)
    end
    render :nothing => true
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    params.require(:project).permit(:title, :description)
  end
end

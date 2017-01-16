class TasksController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :task, :through => :project

  before_action :set_project
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  # UA[2017/01/10] - WHAT ABOUT SORT AND IMPORT
  before_action :set_performer, only: [:create, :update, :destroy, :set_state, :assigned_to_me]

  def index
    cookies[:tasks_visibility] = params[:visibility] || cookies[:tasks_visibility]
    @visibility = cookies[:tasks_visibility] || 'all'

    @task = @project.tasks.new

    @tasks = @project.tasks.with_state(@visibility).search(params[:search_text]).order!('position')
    @tasks = @tasks.tagged_with(params[:tags]) if params[:tags].present?
    @tasks = @tasks.having_ownership(params[:owner]) if params[:owner].present?

    respond_to do |format|
      format.html
      # Export all Tasks shown on index page in sequence. If You want to include completed tasks you have to show them on index.
      format.csv { send_data @tasks.to_csv }
    end
  end

  def show
    @commentable = @task
    @comments = @commentable.comments
    @comment = Comment.new
  end

  def new
    @task = @project.tasks.new
  end

  def create
    @task = @project.tasks.new(task_params.merge(performer: current_user))
    # GS[2015/12/22] - TODO Refactor this, attr_accessor should do the trick
    @task.attachments_array = params[:attachments_array]

    # UA[2016/12/06] - MOVE THESE MODEL RELATED LOGIC TO AR_CALLBACKS
    if params[:add_files_to_project]
      @project.create_attachments(params[:attachments_array], current_user)
    end

    if @task.save
      # @task.create_activity :create, owner: current_user
      redirect_to [@project, :tasks], notice: 'Task was successfully created.'
    else
      render :new
    end
  end

  def edit
    respond_to do |format|
      format.js
      format.html
    end
  end

  def update
    if @task.update(task_params)
      # @task.create_activity :update, owner: current_user
      redirect_to [@project, @task], notice: 'Task was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @task.destroy
    redirect_to project_tasks_url, notice: 'Task was successfully destroyed.'
  end

  def assigned_to_me
    if @task.update_attributes(owner_id: current_user.id)
      'Task is assigned to You'
    else
      'Task could not be assigned to You'
    end
    redirect_to [@project, @task]
  end

  def set_state
    if @task.update_attributes(state: params[:state])
      'State of task is updated successfully'
    else
      'State of task could not be updated'
    end
    redirect_to [@project, @task]
  end

  def sort
    params[:task].each_with_index do |id, index|
      Task.find(id).update_attributes(position: index+1)
    end

    # TODO: Sort in different groups
    render :nothing => true
  end

  def new_import
  end

  def import
    Task.import(params[:file], @project, current_user)
    redirect_to project_tasks_path, notice: 'Tasks imported.'
  end

  private

  def set_task
    @task = @project.tasks.find(params[:id])
  end

  def set_project
    @project = Project.find(params[:project_id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :state, :project_id, :priority, :due_at, :owner_id, :tag_list, :task_type)
    # .merge(requester_id: current_user.id) # use performer in TaskController#set_performer ... Task#set_requester
  end

  def set_performer
    @task.performer = current_user
  end
end

class TasksController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :task, :through => :project

  before_action :set_project
  before_action :set_task,    only: [:show, :edit, :update, :destroy]

  def index
    cookies[:include_completed] = params[:include_completed] if params[:include_completed].present?

    tasks = @project.tasks.search(params[:search_text], cookies[:include_completed] == 'true')
    @grouped_tasks = tasks.order!('position').group_by{ |t| t.task_group_id }

    respond_to do |format|
      format.html
      # Export all Tasks shown on index page in sequence. If You want to include completed tasks you have to show them on index.
      format.csv { send_data tasks.to_csv }
    end
  end

  def show
    @commentable = @task
    @comments = @commentable.comments
    @comment = Comment.new
  end

  def new
    @task = @project.tasks.new
    @task.build_task_group
  end

  def create
    @task = @project.tasks.new(task_params)
    @task.attachments_array=params[:attachments_array]

    if @task.save
      @task.create_activity :create, owner: current_user
      redirect_to [@project, @task], notice: 'Task was successfully created.'
    else
      render :new
    end
  end

  def edit
    @task.build_task_group unless @task.task_group
    @task.task_group.name = nil

    respond_to do |format|
      format.js
      format.html
    end
  end

  def update
    # TODO Refactor this, attr_accessor should do the trick
    @task.attachments_array=params[:attachments_array]

    if @task.update(task_params.except!(:user_id))
      @task.create_activity :update, owner: current_user
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
    flash[:notice]= @task.assigned_to_me current_user
    respond_to :js
  end

  def set_progress
    flash[:notice]= @task.set_progress current_user, params[:progress]
    respond_to :js
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
    Task.import(params[:file],@project, current_user)
    redirect_to project_tasks_path, notice: "Tasks imported."
  end

  private

  def set_task
    @task = @project.tasks.find(params[:id])
  end

  def set_project
    @project = Project.find(params[:project_id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :progress, :project_id, :priority, :due_at, :task_group_id, :assigned_to, :task_group_attributes => [:name])
        .deep_merge(user_id: current_user.id, task_group_attributes: { project: @project, creator: current_user} )
  end
end

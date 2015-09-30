class TasksController < ApplicationController
  before_action :set_project
  before_action :set_task,    only: [:show, :edit, :update, :destroy]

  def index
    @tasks = @project.tasks
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
    @task.attachments_array=params[:attachments_array]

    if @task.update(task_params)
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

  private

  def set_task
    @task = @project.tasks.find(params[:id])
  end

  def set_project
    @project = current_user.projects.find(params[:project_id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :project_id, :priority, :due_at, :task_group_id, :task_group_attributes => [:name])
  end
end

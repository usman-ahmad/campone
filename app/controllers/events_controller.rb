class EventsController < ApplicationController
  before_action :set_project
  before_action :set_event, only: [:edit, :update]

  def index
    @event = @project.events.build
    @task  = @project.tasks.build
    @task.build_task_group
  end

  def show
  end

  def new
  end

  def create
    @event = @project.events.new(event_params)
    @saved = @event.save

    respond_to do |format|
      format.js
    end
  end

  def update
    @saved = @event.update(event_params)

    respond_to do |format|
      format.js
    end
  end

  def edit
    respond_to do |format|
      format.js
    end
  end

  def get_events
    render :text => @project.json_events_for_calender
  end

  private

  def set_event
    @event = @project.events.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :description, :due_at)
  end

  def set_project
    @project = Project.find(params[:project_id])
  end

end

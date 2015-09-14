class EventsController < ApplicationController
  before_action :set_project

  def index
    @event = @project.events.build
  end

  def show
  end

  def new
  end

  def create
    @event = @project.events.new(event_params)

    if @event.save
      flash[:notice] = 'Event was successfully created.'
    end

    redirect_to [@project, :events]
  end

  def edit
  end

  def get_events
    render :text => @project.json_events_for_calender
  end

  private

  def event_params
    params.require(:event).permit(:title, :description, :due_at)
  end

  def set_project
    @project = current_user.projects.find(params[:project_id])
  end

end

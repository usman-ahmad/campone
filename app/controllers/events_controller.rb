class EventsController < ApplicationController
  before_action :set_project
  before_action :set_event, only: [:edit]

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
    @project = current_user.projects.find(params[:project_id])
  end

end

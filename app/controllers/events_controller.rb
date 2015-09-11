class EventsController < ApplicationController
  before_action :set_project

  def index
  end

  def new
  end

  def create
  end

  def get_events
    render :text => @project.json_events_for_calender
  end

  private

  def set_project
    @project = current_user.projects.find(params[:project_id])
  end

end

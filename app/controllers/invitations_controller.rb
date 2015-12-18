class InvitationsController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :contribution, :through => :project

  before_action :set_project
  def new
    @contributions = @project.contributions
  end

  def create
    user = User.where(email: params[:email]).first

    unless user
      user = User.invite!(email: params[:email]) if params[:email].present?
    end

    @project.contributions.create(user: user, role: params[:role] ) if params[:email].present?
    redirect_to :back
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
end

class InvitationsController < ApplicationController

  before_action :set_project
  def new
    @invitations = @project.invitations
  end

  def create
    user = User.where(email: params[:email]).first

    unless user
      user = User.invite!(email: params[:email])
    end

    @project.invitations.create(user: user, role: params[:role] )
    redirect_to :back
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
end

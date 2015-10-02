class InvitationsController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :invitation, :through => :project

  before_action :set_project
  def new
    @invitations = @project.invitations
  end

  def create
    user = User.where(email: params[:email]).first

    unless user
      user = User.invite!(email: params[:email]) if params[:email].present?
    end

    @project.invitations.create(user: user, role: params[:role] ) if params[:email].present?
    redirect_to :back
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
end

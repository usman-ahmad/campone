class ContributionsController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :contribution, :through => :project

  before_action :set_project
  before_action :set_contribution, except: [:new, :create, :index]

  def index
  end

  def new
    @contribution  = Contribution.new
    @contributions = @project.contributions
  end

  def create
    contribution =  @project.contributions.create(contribution_params)
    flash[:alert] = contribution.valid? ? 'Invitations sent.' : contribution.errors.full_messages.join
    redirect_back(fallback_location: project_path(@project))
  end

  def edit
  end

  def update
    if @contribution.update_attributes(contribution_params)
      flash[:alert] = 'Updated successfully.'
    else
      flash[:alert] = @contribution.errors.full_messages.join
    end

    redirect_back(fallback_location: project_path(@project))
  end

  def destroy
    @contribution.destroy
    redirect_to project_path(@project), notice: 'Removed from contributors.'
  end

  def resend_invitation
    @contribution.resend_invitation
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_contribution
    @contribution = @project.contributions.find(params[:id])
  end

  def contribution_params
    params.require(:contribution).permit(:email,:role)
  end
end

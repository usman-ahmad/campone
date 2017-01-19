class ContributionsController < ApplicationController
  # This hook must come before authorization
  before_action :set_contribution_by_token, only: [:join]

  load_and_authorize_resource :project
  load_and_authorize_resource :contribution, :through => :project

  before_action :set_project, except: [:join]
  before_action :set_contribution, except: [:new, :create, :index, :join]

  def index
  end

  def new
    @contribution = Contribution.new
    @contributions = @project.contributions
  end

  def create
    contribution = @project.contributions.create(contribution_params.merge(inviter: current_user))
    if contribution.persisted?
      # send invitation email if user exist in system (prevent duplicate email if already sent by devise invitable)
      UserMailer.contribution_mail(contribution).deliver if contribution.user.accepted_or_not_invited?
      flash[:alert] = 'Invitations sent.'
    else
      flash[:alert] = contribution.errors.full_messages.join
    end

    redirect_back(fallback_location: project_path(@project))
  end

  def edit
  end

  def update
    @contribution.assign_attributes(contribution_params)

    # if cannot create contribution with above given values
    if cannot? :update, @contribution
      flash[:alert] = 'You can not assign these these values.'
    elsif @contribution.save
      flash[:alert] = 'Updated successfully.'
    else
      flash[:alert] = @contribution.errors.full_messages.join
    end

    redirect_back(fallback_location: contributors_project_path(@project))
  end

  def destroy
    @contribution.destroy
    redirect_back fallback_location: contributors_project_path(@project), notice: 'Removed from contributors.'
  end

  def resend_invitation
    @contribution.resend_invitation
    flash[:alert] = 'Invitation email sent successfully.'
    redirect_back(fallback_location: project_path(@project))
  end

  def join
    if @contribution.update_attributes(status: 'joined')
      flash[:alert] = 'You have successfully joined this project.'
    else
      flash[:alert] = 'Something went wrong. We are unable to change your status.'
    end

    redirect_to project_stories_path(@contribution.project)
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_contribution
    @contribution = @project.contributions.find(params[:id])
  end

  def set_contribution_by_token
    @contribution = Contribution.where(token: params[:id]).first
  end

  def contribution_params
    params.require(:contribution).permit(:email, :role)
  end
end

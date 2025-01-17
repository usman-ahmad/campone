class ContributionsController < ApplicationController
  # This hook must come before authorization
  before_action :set_contribution_by_token, only: [:join]

  load_and_authorize_resource :project
  load_and_authorize_resource :contribution, through: :project

  def create
    contribution = @project.contributions.build(contribution_params.merge(inviter: current_user))
    if contribution.save
      # send invitation email if user exist in system (prevent duplicate email if already sent by devise invitable)
      contribution.send_invitation_email unless contribution.user_just_created
      flash[:alert] = 'Invitations sent.'
    else
      flash[:alert] = contribution.errors.full_messages.join
    end

    redirect_back(fallback_location: project_path(@project))
  end

  def resend_invitation
    @contribution.send_invitation_email
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

  # UA[2019/02/25] TODO: Remove extra files after testing on production
  # def index
  # end
  #
  # def new
  #   @contribution = Contribution.new
  #   @contributions = @project.contributions
  # end
  #
  # def edit
  # end
  #
  # def update
  #   @contribution.assign_attributes(contribution_params)
  #
  #   # if cannot create contribution with above given values
  #   if cannot? :update, @contribution
  #     flash[:alert] = 'You can not assign these values.'
  #   elsif @contribution.save
  #     flash[:alert] = 'Updated successfully.'
  #   else
  #     flash[:alert] = @contribution.errors.full_messages.join
  #   end
  #
  #   redirect_back(fallback_location: contributors_project_path(@project))
  # end

  def update_initials
    if @contribution.update(initials: params[:contribution][:initials])
      respond_to do |format|
        format.html {redirect_back fallback_location: contributors_project_path(@project), notice: 'Initials successfully updated.'}
        format.json {render @contribution.as_json}
      end
    else
      respond_to do |format|
        format.html {redirect_back fallback_location: contributors_project_path(@project), alert: 'Initials could not be updated.'}
        format.json {render json: @contribution.errors.full_messages, status: :unprocessable_entity}
      end
    end
  end

  def update_role
    if @contribution.update(role: params[:contribution][:role])
      respond_to do |format|
        format.html {redirect_back fallback_location: contributors_project_path(@project), notice: 'Role successfully updated.'}
        format.json {render @contribution.as_json}
      end
    else
      respond_to do |format|
        format.html {redirect_back fallback_location: contributors_project_path(@project), alert: @contribution.errors.full_messages.join(' ')}
        format.json {render json: @contribution.errors.full_messages, status: :unprocessable_entity}
      end
    end
  end

  def destroy
    @contribution.destroy
    redirect_back fallback_location: contributors_project_path(@project), notice: 'Removed from contributors.'
  end

  private

  # def set_contribution
  #   @contribution = @project.contributions.where(user: current_user).first
  # end

  def set_contribution_by_token
    @contribution = Contribution.where(token: params[:id]).first
  end

  def contribution_params
    params.require(:contribution).permit(:email, :role, :name, :initials)
  end
end

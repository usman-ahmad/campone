class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_action :set_user, only: [:finish_signup, :associate_account]
  before_action :set_project, only: :twitter

  def google_oauth2
    @user = User.find_for_oauth(env['omniauth.auth'], current_user)

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: 'Google Oauth2') if is_navigational_format?
    else
      session['devise.google_oauth2_data'] = env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end

  def after_sign_in_path_for(resource)
    if resource.encrypted_password.present?
      super resource
    else
      finish_signup_path(resource)
    end
  end

  def finish_signup
    if request.patch?
      if current_user.update(user_params)
        sign_in(current_user, :bypass => true)
        redirect_to projects_path, notice: 'Your profile was successfully updated.'
      end
    end
  end

  def associate_account
    @user = @user.associate_account(params[:user][:existing_email], params[:user][:password])
    if @user != current_user
      current_user.destroy
      set_flash_message(:notice, :success, kind: 'Existing') if is_navigational_format?
      sign_in_and_redirect @user, event: :authentication
    else
      current_user.errors.add(:base, 'No such existing account.')
      render action: :finish_signup
    end
  end

  def twitter
    @project.integrations.find_or_create_integration(request.env['omniauth.auth'])?
        flash['notice'] = 'successfully integrated twitter account.' :
        flash['notice'] ='integration failed with twitter account.'
    redirect_to project_integrations_path(@project)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit([:name, :email, :password, :password_confirmation])
  end

  def set_project
   @project=current_user.projects.find(params[:project_id])
  end
end



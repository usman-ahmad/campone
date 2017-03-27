class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!

  layout 'public'

  def index
    redirect_to projects_path and return if current_user.present?
    render :layout => false
  end
end

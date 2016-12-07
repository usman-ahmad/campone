class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!

  layout 'welcome'

  def index
    redirect_to projects_path if current_user.present?
  end
end

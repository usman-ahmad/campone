class WelcomeController < ApplicationController
  layout 'welcome'

  def index
    redirect_to projects_path if current_user.present?
  end
end

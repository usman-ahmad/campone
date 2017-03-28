class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!

  layout 'public'

  def index
    redirect_to projects_path and return if current_user.present?

    @available_sections = {
        features: true,
        pricing: false,
        reviews: false,
        contact_us: false,
        brand: false,
        map: false
    }

    render :layout => false
  end
end

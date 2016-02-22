require 'rails_helper'

RSpec.describe IntegrationsController, type: :controller, pending: 'Fix it. Auto generated, does not work with nested resource' do

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "returns http success" do
      get :show
      expect(response).to have_http_status(:success)
    end
  end

end

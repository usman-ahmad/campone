require 'rails_helper'

RSpec.describe AttachmentsController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      pending
      get :index
      expect(response).to have_http_status(:success)
    end
  end

end

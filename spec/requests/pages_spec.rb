require 'rails_helper'

RSpec.describe "Pages", type: :request do
  describe "GET /about" do
    it "returns http success without authentication" do
      get about_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /dashboard" do
    context "when unauthenticated" do
      it "redirects to the sign in page" do
        get dashboard_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated as admin" do
      let(:admin) { create_user(role: :admin) }

      before do
        sign_in admin
      end

      it "returns http success" do
        get dashboard_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end

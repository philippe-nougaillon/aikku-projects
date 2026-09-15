require 'rails_helper'

RSpec.describe "Admin", type: :request do
  describe "GET /admin/mentions_legales" do
    it "returns http success without authentication" do
      get admin_mentions_legales_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/stats" do
    context "when unauthenticated" do
      it "redirects to the login page" do
        get admin_stats_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated as regular user" do
      let(:user) { create_user(role: :utilisateur, email: "regular@example.com") }

      before { sign_in user }

      it "denies access and redirects" do
        get admin_stats_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "when authenticated as super admin" do
      let(:super_admin) { create_user(role: :admin, email: "philippe.nougaillon@aikku.eu") }

      before { sign_in super_admin }

      it "returns http success" do
        get admin_stats_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe "/theme", type: :request do
  let(:account) { create_account }
  let(:user) { create_user(account: account, role: :utilisateur) }

  describe "PATCH /theme" do
    context "when unauthenticated" do
      it "redirects to the login page for HTML request" do
        patch theme_path, params: { theme: "dark" }
        expect(response).to redirect_to(new_user_session_path)
      end

      it "returns unauthorized for JSON request" do
        patch theme_path, params: { theme: "dark" }, headers: { "ACCEPT" => "application/json" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when authenticated" do
      before { sign_in user }

      it "updates the user's theme with valid theme via JSON" do
        patch theme_path, params: { theme: "synthwave" }, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq({ "theme" => "synthwave" })
        expect(user.reload.theme).to eq("synthwave")
      end

      it "updates the user's theme with valid theme via wrapped params" do
        patch theme_path, params: { user: { theme: "dracula" } }, as: :json
        expect(response).to have_http_status(:ok)
        expect(user.reload.theme).to eq("dracula")
      end

      it "updates the user's theme via HTML and redirects" do
        patch theme_path, params: { theme: "emerald" }
        expect(response).to redirect_to(root_path)
        expect(user.reload.theme).to eq("emerald")
      end

      it "rejects invalid theme via JSON" do
        patch theme_path, params: { theme: "non_existent_theme" }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(user.reload.theme).not_to eq("non_existent_theme")
      end
    end
  end

  describe "Theme restoration on subsequent login and page loads" do
    context "when user has a saved theme" do
      before do
        user.update!(theme: "halloween")
        sign_in user
      end

      it "restores the saved theme in the html data-theme attribute" do
        get root_path
        expect(response).to be_successful
        expect(response.body).to include('data-theme="halloween"')
      end

      it "includes the saved theme in the inline synchronization script" do
        get root_path
        expect(response).to be_successful
        expect(response.body).to include('const theme = "halloween";')
        expect(response.body).to include('localStorage.setItem("theme", theme);')
      end
    end

    context "when user has no saved theme" do
      before do
        user.update!(theme: nil)
        sign_in user
      end

      it "defaults to corporate and falls back to localStorage" do
        get root_path
        expect(response).to be_successful
        expect(response.body).to include('data-theme="corporate"')
        expect(response.body).to include('const theme = localStorage.getItem("theme");')
      end
    end

    context "when user is not signed in" do
      it "defaults to corporate and checks localStorage" do
        get new_user_session_path
        expect(response).to be_successful
        expect(response.body).to include('data-theme="corporate"')
        expect(response.body).to include('const theme = localStorage.getItem("theme");')
      end
    end
  end
end

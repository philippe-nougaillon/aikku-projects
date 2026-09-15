require 'rails_helper'

RSpec.describe "/accounts", type: :request do
  let(:account) { create_account }
  let(:admin) { create_user(account: account, role: :admin) }
  let(:regular_user) { create_user(account: account, role: :utilisateur, username: "regular") }
  let(:other_account) { create_account }
  let(:other_admin) { create_user(account: other_account, role: :admin, username: "other_admin") }

  describe "GET /accounts/:id/edit" do
    context "when unauthenticated" do
      it "redirects to the login page" do
        get edit_account_path(account)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when regular user of account" do
      before { sign_in regular_user }

      it "denies access and redirects" do
        get edit_account_path(account)
        expect(response).to redirect_to(root_path)
      end
    end

    context "when admin of another account" do
      before { sign_in other_admin }

      it "denies access and redirects" do
        get edit_account_path(account)
        expect(response).to redirect_to(root_path)
      end
    end

    context "when admin of the account" do
      before { sign_in admin }

      it "renders the edit form" do
        get edit_account_path(account)
        expect(response).to be_successful
      end
    end
  end

  describe "PATCH /accounts/:id" do
    before { sign_in admin }

    it "updates the account and redirects" do
      patch account_path(account), params: { account: { name: "Updated Company" } }
      expect(response).to redirect_to(user_path(admin))
      expect(account.reload.name).to eq("Updated Company")
    end
  end
end

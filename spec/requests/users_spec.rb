require 'rails_helper'

RSpec.describe "/admin/users", type: :request do
  let(:account) { create_account }
  let(:admin) { create_user(account: account, role: :admin) }
  let(:other_user) { create_user(account: account, role: :utilisateur, username: "other_user") }

  describe "GET /admin/users" do
    context "when unauthenticated" do
      it "redirects to the login page" do
        get users_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated as admin" do
      before { sign_in admin }

      it "renders a successful response" do
        get users_path
        expect(response).to be_successful
      end
    end
  end

  describe "GET /admin/users/:id" do
    before { sign_in admin }

    it "renders a successful response" do
      get user_path(other_user)
      expect(response).to be_successful
    end
  end

  describe "GET /admin/users/new" do
    before { sign_in admin }

    it "renders a successful response" do
      get new_user_path
      expect(response).to be_successful
    end
  end

  describe "GET /admin/users/:id/edit" do
    before { sign_in admin }

    it "renders a successful response" do
      get edit_user_path(other_user)
      expect(response).to be_successful
    end
  end

  describe "POST /admin/users" do
    before { sign_in admin }

    context "with valid parameters" do
      let(:valid_params) do
        {
          user: {
            name: "Jane Doe",
            username: "janedoe",
            email: "jane.doe@example.com",
            password: "password123",
            password_confirmation: "password123",
            role: "utilisateur"
          }
        }
      end

      it "creates a new User and redirects to users list" do
        expect {
          post users_path, params: valid_params
        }.to change(User, :count).by(1)
        expect(response).to redirect_to(users_path)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          user: {
            name: "",
            username: "",
            email: "invalid-email"
          }
        }
      end

      it "does not create a new User and returns unprocessable entity" do
        expect {
          post users_path, params: invalid_params
        }.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /admin/users/:id" do
    before { sign_in admin }

    it "updates the user and redirects to user details" do
      patch user_path(other_user), params: { user: { name: "Updated Name" } }
      expect(response).to redirect_to(user_path(other_user))
      expect(other_user.reload.name).to eq("Updated Name")
    end
  end

  describe "DELETE /admin/users/:id" do
    before { sign_in admin }

    it "destroys the user and redirects to users list" do
      user_to_delete = create_user(account: account, role: :utilisateur, username: "to_delete")
      expect {
        delete user_path(user_to_delete)
      }.to change(User, :count).by(-1)
      expect(response).to redirect_to(users_path)
    end
  end

  describe "GET /admin/users/:id/icalendar" do
    it "renders calendar feed without authentication" do
      get icalendar_user_path(other_user)
      expect(response).to be_successful
    end
  end
end

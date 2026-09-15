require 'rails_helper'

RSpec.describe "/todolists", type: :request do
  let(:account) { create_account }
  let(:admin) { create_user(account: account, role: :admin) }
  let(:regular_user) { create_user(account: account, role: :utilisateur, username: "regular_user") }
  let(:project) { create_project(account: account, user: admin, workflow: 1) }
  let!(:todolist) { create_todolist(project: project, name: "Sprint 1") }

  describe "GET /todolists/:id" do
    context "when unauthenticated" do
      it "redirects to the login page" do
        get todolist_path(todolist)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated as project participant" do
      before { sign_in admin }

      it "renders the todolist details" do
        get todolist_path(todolist)
        expect(response).to be_successful
      end

      it "filters todos by search query" do
        create_todo(todolist: todolist, user: admin, name: "Deploy Rails")
        get todolist_path(todolist), params: { search: "Deploy" }
        expect(response).to be_successful
      end
    end

    context "when authenticated as non-participant" do
      before { sign_in regular_user }

      it "denies access and redirects" do
        get todolist_path(todolist)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /todolists/new" do
    context "when admin" do
      before { sign_in admin }

      it "renders the new todolist form" do
        get new_todolist_path(id: project.slug)
        expect(response).to be_successful
      end
    end

    context "when regular user" do
      before { sign_in regular_user }

      it "denies access and redirects" do
        get new_todolist_path(id: project.slug)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST /todolists" do
    before { sign_in admin }

    context "with valid parameters" do
      let(:valid_params) do
        {
          todolist: {
            name: "Sprint 2",
            project_id: project.id
          }
        }
      end

      it "creates a new Todolist and redirects to it" do
        expect {
          post todolists_path, params: valid_params
        }.to change(Todolist, :count).by(1)

        new_todolist = Todolist.last
        expect(new_todolist.name).to eq("Sprint 2")
        expect(response).to redirect_to(todolist_path(new_todolist))
      end
    end
  end

  describe "PATCH /todolists/:id" do
    before { sign_in admin }

    it "updates the todolist and redirects to project" do
      patch todolist_path(todolist), params: { todolist: { name: "Renamed Sprint" } }
      expect(response).to redirect_to(project_path(project))
      expect(todolist.reload.name).to eq("Renamed Sprint")
    end
  end

  describe "DELETE /todolists/:id" do
    before { sign_in admin }

    it "destroys the todolist and redirects to project" do
      todolist_to_delete = create_todolist(project: project, name: "Sprint To Delete")
      expect {
        delete todolist_path(todolist_to_delete)
      }.to change(Todolist, :count).by(-1)
      expect(response).to redirect_to(project_path(project))
    end
  end
end

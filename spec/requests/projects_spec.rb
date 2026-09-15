require 'rails_helper'

RSpec.describe "/projects", type: :request do
  let(:account) { create_account }
  let(:admin) { create_user(account: account, role: :admin) }
  let(:regular_user) { create_user(account: account, role: :utilisateur, username: "regular_user") }
  let!(:project) { create_project(account: account, user: admin, name: "Alpha Project") }

  describe "GET /projects" do
    context "when unauthenticated" do
      it "redirects to the login page" do
        get projects_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      before { sign_in admin }

      it "renders a successful response" do
        get projects_path
        expect(response).to be_successful
      end

      it "filters projects by search term" do
        get projects_path, params: { search: "Alpha" }
        expect(response).to be_successful
      end
    end
  end

  describe "GET /projects/:id" do
    context "when unauthenticated" do
      it "redirects to the login page" do
        get project_path(project)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated as a project participant" do
      before { sign_in admin }

      it "renders the project details" do
        get project_path(project)
        expect(response).to be_successful
      end
    end

    context "when authenticated as a non-participant" do
      before { sign_in regular_user }

      it "denies access and redirects" do
        get project_path(project)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /projects/new" do
    context "when admin" do
      before { sign_in admin }

      it "renders the new project form" do
        get new_project_path
        expect(response).to be_successful
      end
    end

    context "when regular user" do
      before { sign_in regular_user }

      it "denies access and redirects" do
        get new_project_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST /projects" do
    before { sign_in admin }

    context "with valid parameters" do
      let(:valid_params) do
        {
          project: {
            name: "Beta Project",
            description: "Beta description",
            workflow: 1
          }
        }
      end

      it "creates a new Project and redirects to the project" do
        expect {
          post projects_path, params: valid_params
        }.to change(Project, :count).by(1)

        new_project = Project.last
        expect(new_project.name).to eq("Beta Project")
        expect(new_project.users).to include(admin)
        expect(response).to redirect_to(project_path(new_project))
      end
    end
  end

  describe "GET /projects/:id/edit" do
    context "when admin and participant" do
      before { sign_in admin }

      it "renders the edit form" do
        get edit_project_path(project)
        expect(response).to be_successful
      end
    end

    context "when regular user" do
      before { sign_in regular_user }

      it "denies access and redirects" do
        get edit_project_path(project)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PATCH /projects/:id" do
    before { sign_in admin }

    it "updates the project and redirects to project show" do
      patch project_path(project), params: { project: { name: "Renamed Project", workflow: 1 } }
      expect(response).to redirect_to(project_path(project))
      expect(project.reload.name).to eq("Renamed Project")
    end
  end

  describe "DELETE /projects/:id" do
    before { sign_in admin }

    it "destroys the project and redirects to projects list" do
      expect {
        delete project_path(project)
      }.to change(Project, :count).by(-1)
      expect(response).to redirect_to(projects_path)
    end
  end
end

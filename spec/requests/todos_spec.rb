require 'rails_helper'

RSpec.describe "/todos", type: :request do
  let(:account) { create_account }
  let(:admin) { create_user(account: account, role: :admin) }
  let(:regular_user) { create_user(account: account, role: :utilisateur, username: "regular_user") }
  let(:project) { create_project(account: account, user: admin, workflow: 0) }
  let(:todolist) { create_todolist(project: project) }
  let!(:todo) { create_todo(todolist: todolist, user: admin, name: "Initial Todo") }

  describe "GET /todos" do
    context "when unauthenticated" do
      it "redirects to the login page" do
        get todos_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      before { sign_in admin }

      it "renders a successful response" do
        get todos_path
        expect(response).to be_successful
      end

      it "filters by undone status" do
        get todos_path, params: { filter: "todo" }
        expect(response).to be_successful
      end

      it "filters by done status" do
        get todos_path, params: { filter: "done" }
        expect(response).to be_successful
      end

      it "searches by query string" do
        get todos_path, params: { search: "Initial" }
        expect(response).to be_successful
      end
    end
  end

  describe "GET /todos/new" do
    context "when admin" do
      before { sign_in admin }

      it "renders a successful response" do
        get new_todo_path
        expect(response).to be_successful
      end
    end

    context "when regular user" do
      before { sign_in regular_user }

      it "denies access and redirects" do
        get new_todo_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /todos/:id/edit" do
    before { sign_in admin }

    it "renders the edit form for project participants" do
      get edit_todo_path(todo)
      expect(response).to be_successful
    end
  end

  describe "POST /todos" do
    before { sign_in admin }

    context "with valid parameters" do
      let(:valid_params) do
        {
          todo: {
            name: "New Task",
            todolist_id: todolist.id,
            user_id: admin.id
          }
        }
      end

      it "creates a new Todo and redirects to the todolist" do
        expect {
          post todos_path, params: valid_params
        }.to change(Todo, :count).by(1)
        expect(response).to redirect_to(todolist_path(todolist))
      end
    end
  end

  describe "PATCH /todos/:id" do
    before { sign_in admin }

    it "updates the todo and redirects" do
      patch todo_path(todo), params: { todo: { name: "Updated Task Name" } }
      expect(response).to redirect_to(todolist_path(todolist))
      expect(todo.reload.name).to eq("Updated Task Name")
    end
  end

  describe "DELETE /todos/:id" do
    before { sign_in admin }

    it "destroys the todo and redirects to todolist" do
      todo_to_delete = create_todo(todolist: todolist, user: admin, name: "To Delete")
      expect {
        delete todo_path(todo_to_delete)
      }.to change(Todo, :count).by(-1)
      expect(response).to redirect_to(todolist_path(todolist))
    end
  end
end

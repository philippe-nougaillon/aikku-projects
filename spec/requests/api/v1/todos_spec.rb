require 'rails_helper'

RSpec.describe "Api::V1::Todos", type: :request do
  let(:account) { create_account }
  let(:user) { create_user(account: account) }
  let(:project) { create_project(account: account, user: user) }
  let(:todolist) { create_todolist(project: project) }
  let!(:todo) { create_todo(todolist: todolist, user: user, name: "API Todo") }

  describe "GET /api/v1/todos" do
    context "without account slug" do
      it "returns empty or nil data in json" do
        get api_v1_todos_path, as: :json
        expect(response).to be_successful
        json = JSON.parse(response.body)
        expect(json["data"]).to be_nil
      end
    end

    context "with valid account slug" do
      it "returns todos belonging to the account in json" do
        get api_v1_todos_path(slug: account.slug), as: :json
        expect(response).to be_successful
        json = JSON.parse(response.body)
        expect(json["data"]).to be_an(Array)
        expect(json["data"].first["name"]).to eq("API Todo")
      end
    end
  end

  describe "GET /api/v1/todos/:id" do
    it "returns todo, todolist and project data in json" do
      get api_v1_todo_path(todo.slug), params: { todo_slug: todo.slug }, as: :json
      expect(response).to be_successful
      json = JSON.parse(response.body)
      expect(json["data"]).to include("API Todo")
    end
  end
end

require 'rails_helper'

RSpec.describe Todolist, type: :model do
  let(:account) { create_account }
  let(:user) { create_user(account: account) }
  let(:project) { create_project(account: account, user: user) }

  subject(:todolist) do
    described_class.new(
      project: project,
      name: "Sprint Backlog",
      row: 1
    )
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(todolist).to be_valid
    end

    it "is invalid without a name" do
      todolist.name = nil
      expect(todolist).not_to be_valid
      expect(todolist.errors[:name]).to include("doit être rempli(e)")
    end

    it "requires a project" do
      todolist.project = nil
      expect(todolist).not_to be_valid
      expect(todolist.errors[:project]).to be_present
    end
  end

  describe "friendly_id slug" do
    it "generates a slug automatically on save" do
      todolist.save!
      expect(todolist.slug).to be_present
      expect(todolist.slug).to match(/\A[0-9a-f\-]{36}\z/)
    end
  end

  describe "associations and dependent destroy" do
    let!(:persisted_list) { create_todolist(project: project, name: "List with items") }
    let!(:todo) { create_todo(todolist: persisted_list, user: user) }

    it "has many todos" do
      expect(persisted_list.todos).to include(todo)
    end

    it "destroys associated todos when destroyed" do
      expect { persisted_list.destroy }.to change(Todo, :count).by(-1)
    end

    it "destroys associated logs when destroyed" do
      Log.create!(project: project, todolist: persisted_list, user: user, description: "List log", action_id: 1)
      expect { persisted_list.destroy }.to change(Log, :count).by(-1)
    end
  end

  describe "#pct_avancee" do
    let(:persisted_list) { create_todolist(project: project) }

    it "returns 0 when there are no todos without raising ZeroDivisionError" do
      expect(persisted_list.pct_avancee).to eq(0)
    end

    it "returns 0 when no todos are completed" do
      create_todo(todolist: persisted_list, user: user)
      expect(persisted_list.pct_avancee).to eq(0)
    end

    it "calculates correct completion percentage" do
      t1 = create_todo(todolist: persisted_list, user: user)
      t1.update!(done: true)
      create_todo(todolist: persisted_list, user: user)

      expect(persisted_list.pct_avancee).to eq(50)
    end
  end

  describe "#done?" do
    let(:persisted_list) { create_todolist(project: project) }

    it "returns false when there are no todos" do
      expect(persisted_list.done?).to be false
    end

    it "returns false when at least one todo is undone" do
      t1 = create_todo(todolist: persisted_list, user: user)
      t1.update!(done: true)
      create_todo(todolist: persisted_list, user: user)

      expect(persisted_list.done?).to be false
    end

    it "returns true when all todos are done" do
      t1 = create_todo(todolist: persisted_list, user: user)
      t1.update!(done: true)
      t2 = create_todo(todolist: persisted_list, user: user)
      t2.update!(done: true)

      expect(persisted_list.done?).to be true
    end
  end

  describe "#name_with_indice" do
    it "combines row number and name" do
      todolist.row = 3
      todolist.name = "Specifications"
      expect(todolist.name_with_indice).to eq("3 - Specifications")
    end
  end

  describe "#next_todo" do
    let(:persisted_list) { create_todolist(project: project) }

    it "returns nil when there are no todos" do
      expect(persisted_list.next_todo).to be_nil
    end

    it "returns the first undone todo" do
      t1 = create_todo(todolist: persisted_list, user: user, name: "First Task")
      t1.update!(done: true)
      t2 = create_todo(todolist: persisted_list, user: user, name: "Second Task")

      expect(persisted_list.next_todo).to eq(t2)
    end

    it "returns nil when all todos are done" do
      t1 = create_todo(todolist: persisted_list, user: user)
      t1.update!(done: true)

      expect(persisted_list.next_todo).to be_nil
    end
  end

  describe "#bar_avancee" do
    let(:persisted_list) { create_todolist(project: project) }

    it "renders the progress HTML without error when empty" do
      expect(persisted_list.bar_avancee).to eq("<span id='progress'></span><span id='progress_done'>..........</span>")
    end

    it "renders progress dots proportionally when tasks are completed" do
      t1 = create_todo(todolist: persisted_list, user: user)
      t1.update!(done: true)
      create_todo(todolist: persisted_list, user: user)

      expect(persisted_list.bar_avancee).to eq("<span id='progress'>.....</span><span id='progress_done'>.....</span>")
    end
  end
end

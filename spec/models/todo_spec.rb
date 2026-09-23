require 'rails_helper'

RSpec.describe Todo, type: :model do
  let(:account) { create_account }
  let(:user) { create_user(account: account) }
  let(:project) { create_project(account: account, user: user, name: "Alpha") }
  let(:todolist) { create_todolist(project: project, name: "Sprint 1") }

  subject(:todo) do
    described_class.new(
      todolist: todolist,
      user: user,
      name: "Write specs",
      done: false
    )
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(todo).to be_valid
    end

    it "is invalid without a name" do
      todo.name = nil
      expect(todo).not_to be_valid
      expect(todo.errors[:name]).to include("doit être rempli(e)")
    end

    it "requires a todolist" do
      todo.todolist = nil
      expect(todo).not_to be_valid
      expect(todo.errors[:todolist]).to be_present
    end

    it "requires a user" do
      todo.user = nil
      expect(todo).not_to be_valid
      expect(todo.errors[:user]).to be_present
    end
  end

  describe "friendly_id slug" do
    it "generates a slug automatically on save" do
      todo.save!
      expect(todo.slug).to be_present
      expect(todo.slug).to match(/\A[0-9a-f\-]{36}\z/)
    end
  end

  describe "associations and dependent destroy" do
    let!(:persisted_todo) { create_todo(todolist: todolist, user: user, name: "Task with relations") }

    it "belongs to todolist and user" do
      expect(persisted_todo.todolist).to eq(todolist)
      expect(persisted_todo.user).to eq(user)
    end

    it "has one project through todolist" do
      expect(persisted_todo.project).to eq(project)
    end

    it "destroys associated comments when destroyed" do
      Comment.create!(todo: persisted_todo, user: user, texte: "A comment")
      expect { persisted_todo.destroy }.to change(Comment, :count).by(-1)
    end

    it "destroys associated values when destroyed" do
      table = account.tables.create!(name: "Test Table")
      field = table.fields.create!(name: "Col 1", datatype: :texte)
      Value.create!(table: table, field: field, user: user, todo: persisted_todo, data: "Val")

      expect { persisted_todo.destroy }.to change(Value, :count).by(-1)
    end
  end

  describe "scopes" do
    let!(:done_todo) { create_todo(todolist: todolist, user: user, name: "Done Task").tap { |t| t.update!(done: true) } }
    let!(:undone_todo) { create_todo(todolist: todolist, user: user, name: "Undone Task").tap { |t| t.update!(done: false) } }

    describe ".done" do
      it "returns only completed todos" do
        expect(described_class.done).to include(done_todo)
        expect(described_class.done).not_to include(undone_todo)
      end
    end

    describe ".undone" do
      it "returns only incomplete todos" do
        expect(described_class.undone).to include(undone_todo)
        expect(described_class.undone).not_to include(done_todo)
      end
    end
  end

  describe "naming and preview methods" do
    before { todo.save! }

    describe "#fullname" do
      it "returns project:todolist:todo formatted string" do
        expect(todo.fullname).to eq("Alpha:Sprint 1:Write specs")
      end
    end

    describe "#project_todolist_name" do
      it "returns project:todolist formatted string" do
        expect(todo.project_todolist_name).to eq("Alpha:Sprint 1")
      end
    end

    describe "#preview_name" do
      it "returns empty string when docname is nil without raising error" do
        todo.docname = nil
        expect(todo.preview_name).to eq("")
      end

      it "returns empty string when docname is blank" do
        todo.docname = ""
        expect(todo.preview_name).to eq("")
      end

      it "returns png preview path for pdf documents" do
        todo.docname = "document.pdf"
        todo.docfilename = "abc-123"
        expect(todo.preview_name).to eq("/documents/abc-123.png")
      end

      it "returns direct path for non-pdf documents" do
        todo.docname = "photo.jpg"
        todo.docfilename = "xyz-789"
        expect(todo.preview_name).to eq("/documents/xyz-789")
      end
    end
  end

  describe "tagging" do
    it "allows adding and querying tags" do
      todo.tag_list = "urgent, frontend"
      todo.save!
      expect(todo.tag_list).to contain_exactly("urgent", "frontend")
    end
  end
end

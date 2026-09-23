require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:account) { create_account }
  let(:user) { create_user(account: account) }
  let(:project) { create_project(account: account, user: user) }
  let(:todolist) { create_todolist(project: project) }
  let(:todo) { create_todo(todolist: todolist, user: user) }

  subject(:comment) do
    described_class.new(
      todo: todo,
      user: user,
      texte: "Initial comment",
      audience: 0
    )
  end

  describe "validations and associations" do
    it "is valid with valid attributes" do
      expect(comment).to be_valid
    end

    it "requires a todo" do
      comment.todo = nil
      expect(comment).not_to be_valid
      expect(comment.errors[:todo]).to be_present
    end

    it "requires a user" do
      comment.user = nil
      expect(comment).not_to be_valid
      expect(comment.errors[:user]).to be_present
    end

    it "has access to todolist and project through todo" do
      comment.save!
      expect(comment.todolist).to eq(todolist)
      expect(comment.project).to eq(project)
    end
  end

  describe "default scope" do
    it "orders comments in descending order of created_at" do
      c1 = described_class.create!(todo: todo, user: user, texte: "First", created_at: 2.hours.ago)
      c2 = described_class.create!(todo: todo, user: user, texte: "Second", created_at: 1.hour.ago)

      expect(described_class.where(todo: todo)).to eq([c2, c1])
    end
  end

  describe "LogConcern logging" do
    it "creates a Log record when log_changes is invoked" do
      comment.save!
      expect {
        comment.log_changes(:comment, user.id)
      }.to change(Log, :count).by(1)

      log = Log.first
      expect(log.action_id).to eq(3) # 3 = comment action value
      expect(log.project_id).to eq(project.id)
    end
  end
end

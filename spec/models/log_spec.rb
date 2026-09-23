require 'rails_helper'

RSpec.describe Log, type: :model do
  let(:account) { create_account }
  let(:user) { create_user(account: account) }
  let(:project) { create_project(account: account, user: user) }
  let(:todolist) { create_todolist(project: project) }

  subject(:log) do
    described_class.new(
      project: project,
      user: user,
      description: "Added a task",
      action_id: 0
    )
  end

  describe "validations and associations" do
    it "is valid with project and user" do
      expect(log).to be_valid
    end

    it "is valid without a todolist" do
      log.todolist = nil
      expect(log).to be_valid
    end

    it "is valid with an associated todolist" do
      log.todolist = todolist
      expect(log).to be_valid
      expect(log.todolist).to eq(todolist)
    end

    it "requires a project" do
      log.project = nil
      expect(log).not_to be_valid
      expect(log.errors[:project]).to be_present
    end

    it "requires a user" do
      log.user = nil
      expect(log).not_to be_valid
      expect(log.errors[:user]).to be_present
    end
  end

  describe "scopes" do
    describe "default_scope" do
      it "orders logs in descending order of created_at" do
        l1 = described_class.create!(project: project, user: user, description: "Older", action_id: 0, created_at: 2.hours.ago)
        l2 = described_class.create!(project: project, user: user, description: "Newer", action_id: 0, created_at: 1.hour.ago)

        expect(described_class.where(project: project)).to eq([l2, l1])
      end
    end

    describe ".except_comments" do
      it "excludes comment action logs (action_id == 3)" do
        regular_log = described_class.create!(project: project, user: user, description: "Edit", action_id: 1)
        comment_log = described_class.create!(project: project, user: user, description: "Commented", action_id: 3)

        expect(described_class.except_comments).to include(regular_log)
        expect(described_class.except_comments).not_to include(comment_log)
      end
    end

    describe ".documents" do
      it "includes only document action logs (action_id == 4)" do
        doc_log = described_class.create!(project: project, user: user, description: "Document", action_id: 4)
        other_log = described_class.create!(project: project, user: user, description: "Other", action_id: 0)

        expect(described_class.documents).to include(doc_log)
        expect(described_class.documents).not_to include(other_log)
      end
    end
  end
end

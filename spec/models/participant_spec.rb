require 'rails_helper'

RSpec.describe Participant, type: :model do
  let(:account) { create_account }
  let(:user) { create_user(account: account) }
  let(:project) { create_project(account: account, user: user) }
  let(:other_user) { create_user(account: account, username: "participant_user") }

  subject(:participant) do
    described_class.new(
      project: project,
      user: other_user,
      want_notification: false
    )
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(participant).to be_valid
    end

    it "requires a user" do
      participant.user = nil
      expect(participant).not_to be_valid
      expect(participant.errors[:user]).to be_present
    end

    it "requires a project" do
      participant.project = nil
      expect(participant).not_to be_valid
      expect(participant.errors[:project]).to be_present
    end

    it "enforces uniqueness of user_id scoped to project_id" do
      participant.save!
      duplicate = described_class.new(project: project, user: other_user)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to be_present
    end

    it "allows the same user in different projects" do
      participant.save!
      other_project = create_project(account: account, user: user, name: "Second Project")
      another_participant = described_class.new(project: other_project, user: other_user)
      expect(another_participant).to be_valid
    end
  end

  describe "friendly_id slug" do
    it "generates a slug automatically on save" do
      participant.save!
      expect(participant.slug).to be_present
      expect(participant.slug).to match(/\A[0-9a-f\-]{36}\z/)
    end
  end

  describe "associations" do
    it "belongs to project and user" do
      expect(participant.project).to eq(project)
      expect(participant.user).to eq(other_user)
    end
  end

  describe "scopes" do
    describe ".notification_subcribers" do
      it "returns only participants who want notifications" do
        subscribed = described_class.create!(project: project, user: other_user, want_notification: true)
        third_user = create_user(account: account, username: "third_user")
        unsubscribed = described_class.create!(project: project, user: third_user, want_notification: false)

        expect(described_class.notification_subcribers).to include(subscribed)
        expect(described_class.notification_subcribers).not_to include(unsubscribed)
      end
    end
  end
end

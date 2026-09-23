require 'rails_helper'

RSpec.describe Account, type: :model do
  subject(:account) { described_class.new(name: "Acme Corp") }

  describe "validations" do
    it "is valid with a name" do
      expect(account).to be_valid
    end

    it "is invalid without a name" do
      account.name = nil
      expect(account).not_to be_valid
      expect(account.errors[:name]).to include("doit être rempli(e)")
    end

    it "enforces uniqueness of name" do
      account.save!
      duplicate = described_class.new(name: "Acme Corp")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to be_present
    end
  end

  describe "friendly_id slug" do
    it "generates a slug automatically on save" do
      account.save!
      expect(account.slug).to be_present
      expect(account.slug).to match(/\A[0-9a-f\-]{36}\z/)
    end
  end

  describe "associations and dependent destroy" do
    before { account.save! }

    it "destroys associated projects, users, tables, templates, and mail_logs" do
      user = create_user(account: account)
      project = create_project(account: account, user: user)
      table = account.tables.create!(name: "Test Table")
      template = account.templates.create!(name: "Test Template")
      mail_log = account.mail_logs.create!(to: "dest@example.com", subject: "Test", message_id: "123")

      expect { account.destroy }.to change(Project, :count).by(-1)
        .and change(User, :count).by(-1)
        .and change(Table, :count).by(-1)
        .and change(Template, :count).by(-1)
        .and change(MailLog, :count).by(-1)
    end
  end

  describe "nested attributes" do
    it "creates associated users via nested attributes" do
      acc = described_class.new(
        name: "Nested Co",
        users_attributes: [
          {
            name: "Nested User",
            username: "nested_user",
            email: "nested@example.com",
            password: "password123",
            password_confirmation: "password123",
            role: :admin
          }
        ]
      )
      expect { acc.save! }.to change(User, :count).by(1)
      expect(acc.users.first.name).to eq("Nested User")
    end
  end
end

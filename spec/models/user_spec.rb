require 'rails_helper'

RSpec.describe User, type: :model do
  let(:account) { create_account }

  subject(:user) do
    described_class.new(
      account: account,
      email: "test@example.com",
      username: "testuser",
      name: "Test User",
      password: "password123",
      password_confirmation: "password123",
      role: :utilisateur
    )
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(user).to be_valid
    end

    it "is invalid without a name" do
      user.name = nil
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("doit être rempli(e)")
    end

    it "is invalid without a username" do
      user.username = nil
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include("doit être rempli(e)")
    end

    it "enforces uniqueness of username" do
      user.save!
      duplicate = described_class.new(
        account: account,
        email: "other@example.com",
        username: "testuser",
        name: "Other User",
        password: "password123",
        password_confirmation: "password123"
      )
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:username]).to be_present
    end

    it "is invalid without an email" do
      user.email = nil
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "enforces uniqueness of email" do
      user.save!
      duplicate = described_class.new(
        account: account,
        email: "test@example.com",
        username: "different_user",
        name: "Other User",
        password: "password123",
        password_confirmation: "password123"
      )
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to be_present
    end

    it "requires password to be at least 6 characters" do
      user.password = "12345"
      user.password_confirmation = "12345"
      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end

    it "requires an account" do
      user.account = nil
      expect(user).not_to be_valid
      expect(user.errors[:account]).to be_present
    end

    it "allows blank theme" do
      user.theme = nil
      expect(user).to be_valid
      user.theme = ""
      expect(user).to be_valid
    end

    it "accepts valid themes from THEMES" do
      described_class::THEMES.each do |theme_name|
        user.theme = theme_name
        expect(user).to be_valid
      end
    end

    it "rejects invalid themes" do
      user.theme = "invalid_theme_xyz"
      expect(user).not_to be_valid
      expect(user.errors[:theme]).to be_present
    end
  end

  describe "enums" do
    it "defines roles for utilisateur and admin" do
      expect(described_class.roles).to eq({ "utilisateur" => 0, "admin" => 1 })
    end

    it "defaults role to utilisateur" do
      new_user = described_class.new
      expect(new_user.role).to eq("utilisateur")
    end

    it "supports admin role" do
      user.role = :admin
      expect(user).to be_admin
    end
  end

  describe "friendly_id slug" do
    it "generates a slug automatically on save" do
      user.save!
      expect(user.slug).to be_present
      expect(user.slug).to match(/\A[0-9a-f\-]{36}\z/)
    end
  end

  describe "associations" do
    it "belongs to account" do
      expect(user.account).to eq(account)
    end

    it "destroys associated participants when deleted" do
      user.save!
      project = create_project(account: account, user: user)
      expect { user.destroy }.to change(Participant, :count).by(-1)
    end
  end

  describe "#same_account" do
    let(:same_account_user) { create_user(account: account, username: "same_acc") }
    let(:other_account) { create_account }
    let(:other_account_user) { create_user(account: other_account, username: "other_acc") }

    before { user.save! }

    it "returns true when both users share the same account" do
      expect(user.same_account(same_account_user)).to be true
    end

    it "returns false when users belong to different accounts" do
      expect(user.same_account(other_account_user)).to be false
    end
  end

  describe ".from_omniauth" do
    let(:auth_hash) do
      OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: "123456789",
        info: {
          email: "omniauth@example.com",
          name: "OmniAuth User",
          image: "https://example.com/avatar.png"
        }
      )
    end

    context "when user already exists with that email" do
      let!(:existing_user) do
        create_user(account: account, email: "omniauth@example.com", username: "existing_omni")
      end

      it "returns the existing user without creating a new one" do
        expect {
          result = described_class.from_omniauth(auth_hash)
          expect(result).to eq(existing_user)
        }.not_to change(described_class, :count)
      end
    end

    context "when user does not exist" do
      let(:fake_image) { StringIO.new("fake image binary") }

      before do
        allow(URI).to receive(:open).and_return(fake_image)
        welcome_project_double = instance_double(CreateWelcomeProject, call: true)
        allow(CreateWelcomeProject).to receive(:new).and_return(welcome_project_double)
      end

      it "creates a new user with admin role and an account" do
        expect {
          result = described_class.from_omniauth(auth_hash)
          expect(result).to be_persisted
          expect(result.email).to eq("omniauth@example.com")
          expect(result.name).to eq("OmniAuth User")
          expect(result.username).to eq("omniauth")
          expect(result.role).to eq("admin")
          expect(result.account).to be_present
          expect(result.account.name).to eq("omniauth")
        }.to change(described_class, :count).by(1).and change(Account, :count).by(1)
      end
    end
  end
end

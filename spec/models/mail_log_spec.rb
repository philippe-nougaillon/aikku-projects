require 'rails_helper'

RSpec.describe MailLog, type: :model do
  let(:account) { create_account }

  subject(:mail_log) do
    described_class.new(
      account: account,
      to: "recipient@example.com",
      subject: "Important Notification",
      message_id: "msg-123456"
    )
  end

  describe "associations and validations" do
    it "is valid with valid attributes" do
      expect(mail_log).to be_valid
    end

    it "belongs to an account" do
      expect(mail_log.account).to eq(account)
    end

    it "requires an account" do
      mail_log.account = nil
      expect(mail_log).not_to be_valid
      expect(mail_log.errors[:account]).to be_present
    end
  end

  describe "default scope" do
    it "orders mail logs in descending order of created_at" do
      m1 = described_class.create!(account: account, to: "r1@example.com", subject: "Older", message_id: "1", created_at: 2.hours.ago)
      m2 = described_class.create!(account: account, to: "r2@example.com", subject: "Newer", message_id: "2", created_at: 1.hour.ago)

      expect(described_class.where(account: account)).to eq([m2, m1])
    end
  end
end

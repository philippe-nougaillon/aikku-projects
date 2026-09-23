require 'rails_helper'

RSpec.describe Template, type: :model do
  let(:account) { create_account }

  subject(:template) do
    described_class.new(
      account: account,
      name: "Agile Sprint Template",
      project: "Standard Project"
    )
  end

  describe "associations and validations" do
    it "is valid with valid attributes" do
      expect(template).to be_valid
    end

    it "belongs to an account" do
      expect(template.account).to eq(account)
    end

    it "requires an account" do
      template.account = nil
      expect(template).not_to be_valid
      expect(template.errors[:account]).to be_present
    end
  end
end

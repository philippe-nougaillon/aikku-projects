require 'rails_helper'

RSpec.describe Table, type: :model do
  let(:account) { create_account }

  subject(:table) do
    described_class.new(
      account: account,
      name: "Custom Data Table"
    )
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(table).to be_valid
    end

    it "is invalid without a name" do
      table.name = nil
      expect(table).not_to be_valid
      expect(table.errors[:name]).to include("doit être rempli(e)")
    end

    it "requires an account" do
      table.account = nil
      expect(table).not_to be_valid
      expect(table.errors[:account]).to be_present
    end
  end

  describe "friendly_id slug" do
    it "generates a slug automatically on save" do
      table.save!
      expect(table.slug).to be_present
      expect(table.slug).to match(/\A[0-9a-f\-]{36}\z/)
    end
  end

  describe "associations and dependent destroy" do
    before { table.save! }

    it "destroys associated fields and values when destroyed" do
      user = create_user(account: account)
      field = table.fields.create!(name: "Price", datatype: :euros)
      table.values.create!(field: field, user: user, record_index: 1, data: "100")

      expect { table.destroy }.to change(Field, :count).by(-1)
        .and change(Value, :count).by(-1)
    end
  end

  describe "#size" do
    before { table.save! }

    it "returns 0 when there are no values" do
      expect(table.size).to eq(0)
    end

    it "returns the count of unique record indices" do
      user = create_user(account: account)
      f1 = table.fields.create!(name: "Field 1", datatype: :texte)
      f2 = table.fields.create!(name: "Field 2", datatype: :nombre)

      # Two values for record_index 1
      table.values.create!(field: f1, user: user, record_index: 1, data: "Alpha")
      table.values.create!(field: f2, user: user, record_index: 1, data: "10")

      # One value for record_index 2
      table.values.create!(field: f1, user: user, record_index: 2, data: "Beta")

      expect(table.size).to eq(2)
    end
  end
end

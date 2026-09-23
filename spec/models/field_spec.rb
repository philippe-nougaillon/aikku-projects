require 'rails_helper'

RSpec.describe Field, type: :model do
  let(:account) { create_account }
  let(:table) { account.tables.create!(name: "Items") }

  subject(:field) do
    described_class.new(
      table: table,
      name: "Quantité",
      datatype: :nombre
    )
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(field).to be_valid
    end

    it "is invalid without a name" do
      field.name = nil
      expect(field).not_to be_valid
      expect(field.errors[:name]).to include("doit être rempli(e)")
    end

    it "is invalid without a datatype" do
      field.datatype = nil
      expect(field).not_to be_valid
      expect(field.errors[:datatype]).to include("doit être rempli(e)")
    end

    it "requires a table" do
      field.table = nil
      expect(field).not_to be_valid
      expect(field.errors[:table]).to be_present
    end
  end

  describe "enum datatype" do
    it "defines expected datatypes" do
      expected_keys = %w[texte nombre euros date oui_non? liste]
      expect(described_class.datatypes.keys).to eq(expected_keys)
    end

    it "responds to datatype predicates" do
      field.datatype = :euros
      expect(field.euros?).to be true
      expect(field.texte?).to be false
    end
  end

  describe "associations and dependent destroy" do
    before { field.save! }

    it "destroys associated values when destroyed" do
      user = create_user(account: account)
      table.values.create!(field: field, user: user, record_index: 1, data: "42")

      expect { field.destroy }.to change(Value, :count).by(-1)
    end
  end
end

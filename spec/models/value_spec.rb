require 'rails_helper'

RSpec.describe Value, type: :model do
  let(:account) { create_account }
  let(:user) { create_user(account: account) }
  let(:table) { account.tables.create!(name: "Specs Table") }
  let(:field) { table.fields.create!(name: "Status", datatype: :texte) }
  let(:project) { create_project(account: account, user: user) }
  let(:todolist) { create_todolist(project: project) }
  let(:todo) { create_todo(todolist: todolist, user: user) }

  subject(:value) do
    described_class.new(
      field: field,
      table: table,
      user: user,
      record_index: 1,
      data: "In Progress"
    )
  end

  describe "validations and associations" do
    it "is valid with required associations" do
      expect(value).to be_valid
    end

    it "is valid without a todo" do
      value.todo = nil
      expect(value).to be_valid
    end

    it "is valid with an associated todo" do
      value.todo = todo
      expect(value).to be_valid
      expect(value.todo).to eq(todo)
    end

    it "requires a field" do
      value.field = nil
      expect(value).not_to be_valid
      expect(value.errors[:field]).to be_present
    end

    it "requires a table" do
      value.table = nil
      expect(value).not_to be_valid
      expect(value.errors[:table]).to be_present
    end

    it "requires a user" do
      value.user = nil
      expect(value).not_to be_valid
      expect(value.errors[:user]).to be_present
    end
  end

  describe "scopes" do
    describe ".records_at" do
      it "returns values matching the given record_index" do
        v1 = described_class.create!(field: field, table: table, user: user, record_index: 1, data: "A")
        v2 = described_class.create!(field: field, table: table, user: user, record_index: 2, data: "B")

        expect(described_class.records_at(1)).to include(v1)
        expect(described_class.records_at(1)).not_to include(v2)
      end
    end
  end
end

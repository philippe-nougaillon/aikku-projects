# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuditsHelper, type: :helper do
  describe '#prettify' do
    it 'returns empty array when audit is nil' do
      expect(helper.prettify(nil)).to eq([])
    end

    it 'returns empty array when audited_changes is nil or empty' do
      audit = Struct.new(:action, :audited_changes).new('update', nil)
      expect(helper.prettify(audit)).to eq([])

      audit = Struct.new(:action, :audited_changes).new('update', {})
      expect(helper.prettify(audit)).to eq([])
    end

    context 'when action is update' do
      it 'does not raise error when change value is nil (potential undefined method first for nil)' do
        audit = Struct.new(:action, :audited_changes).new('update', { 'picturelink' => nil })
        expect { helper.prettify(audit) }.not_to raise_error
        expect(helper.prettify(audit)).to eq([])
      end

      it 'handles scalar change value from combined audits' do
        audit = Struct.new(:action, :audited_changes).new('update', { 'name' => 'Nougaillon' })
        expect(helper.prettify(audit)).to eq(["'Name' était 'Nougaillon'"])
      end

      it 'handles array changes with from and to' do
        audit = Struct.new(:action, :audited_changes).new('update', { 'role' => [0, 1] })
        expect(helper.prettify(audit)).to eq(["'Role' modifié de '0' à '1'"])
      end

      it 'handles array changes with nil old value' do
        audit = Struct.new(:action, :audited_changes).new('update', { 'role' => [nil, 1] })
        expect(helper.prettify(audit)).to eq(["'Role' modifié de '' à '1'"])
      end

      it 'handles array changes with nil new value' do
        audit = Struct.new(:action, :audited_changes).new('update', { 'role' => [1, nil] })
        expect(helper.prettify(audit)).to eq(["'Role' modifié de '1' à ''"])
      end

      it 'skips array changes when both values are blank' do
        audit = Struct.new(:action, :audited_changes).new('update', { 'role' => [nil, nil] })
        expect(helper.prettify(audit)).to eq([])
      end
    end

    context 'when action is create' do
      it 'formats scalar changes with initialisé à' do
        audit = Struct.new(:action, :audited_changes).new('create', { 'name' => 'Mon projet' })
        expect(helper.prettify(audit)).to eq(["'Name' initialisé à 'Mon projet'"])
      end

      it 'skips blank values' do
        audit = Struct.new(:action, :audited_changes).new('create', { 'logo' => nil })
        expect(helper.prettify(audit)).to eq([])
      end
    end

    context 'when foreign key user_id is changed' do
      let(:user) { create_user }

      it 'formats user_id integer to user email' do
        audit = Struct.new(:action, :audited_changes).new('create', { 'user_id' => user.id })
        expect(helper.prettify(audit)).to eq(["'User' initialisé à '#{user.email}'"])
      end

      it 'formats user_id array to email change' do
        audit = Struct.new(:action, :audited_changes).new('update', { 'user_id' => [nil, user.id] })
        expect(helper.prettify(audit)).to eq(["'User' changé de '' à '#{user.email}'"])
      end

      it 'handles non-existent user gracefully' do
        audit = Struct.new(:action, :audited_changes).new('create', { 'user_id' => 999_999 })
        expect { helper.prettify(audit) }.not_to raise_error
        expect(helper.prettify(audit)).to eq(["'User' initialisé à '999999'"])
      end
    end
  end
end

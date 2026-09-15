# frozen_string_literal: true

# Helper to format audit changes for display in audit trail views
module AuditsHelper
  def prettify(audit)
    return [] if audit&.audited_changes.blank?

    pretty_changes = []
    audit.audited_changes.each do |attr_name, change|
      format_change(audit, attr_name.to_s, change, pretty_changes)
    end
    pretty_changes
  end

  private

  def format_change(audit, attr_name, change, pretty_changes)
    key = attr_name.humanize

    if relation_attribute?(audit, attr_name, 'user')
      format_user_change(key, audit.audited_changes['user_id'] || change, pretty_changes)
    elsif relation_attribute?(audit, attr_name, 'contact')
      format_contact_change(key, audit.audited_changes['contact_id'] || change, pretty_changes)
    elsif audit.action == 'update' && change.is_a?(Array)
      format_update_change(key, change, pretty_changes)
    else
      format_scalar_change(key, change, audit.action, pretty_changes)
    end
  end

  def relation_attribute?(audit, attr_name, relation)
    id_key = "#{relation}_id"
    attr_name == id_key || (attr_name.humanize == relation.capitalize && audit.audited_changes.key?(id_key))
  end

  def format_user_change(key, ids, pretty_changes)
    format_relation_change(key, ids, ->(id) { User.find_by(id: id)&.email }, pretty_changes)
  end

  def format_contact_change(key, ids, pretty_changes)
    format_relation_change(key, ids, ->(id) { Contact.find_by(id: id)&.nom if defined?(Contact) }, pretty_changes)
  end

  def format_relation_change(key, ids, label_getter, pretty_changes)
    case ids
    when Integer
      label = label_getter.call(ids)
      pretty_changes << "'#{key}' initialisé à '#{label || ids}'"
    when Array
      format_relation_array(key, ids, label_getter, pretty_changes)
    end
  rescue StandardError => e
    pretty_changes << "error: '#{e.message}'"
  end

  def format_relation_array(key, ids, label_getter, pretty_changes)
    return if blank_audit_value?(ids.first) && blank_audit_value?(ids.last)

    from = label_getter.call(ids.first) || ids.first if ids.first
    to = label_getter.call(ids.last) || ids.last if ids.last
    pretty_changes << "'#{key}' changé de '#{from}' à '#{to}'"
  end

  def format_update_change(key, change, pretty_changes)
    from = change.first
    to = change.last
    return if blank_audit_value?(from) && blank_audit_value?(to)

    pretty_changes << "'#{key}' modifié de '#{from}' à '#{to}'"
  end

  def format_scalar_change(key, change, action, pretty_changes)
    return if blank_audit_value?(change)

    verb = action == 'create' ? 'initialisé à' : 'était'
    pretty_changes << "'#{key}' #{verb} '#{change}'"
  end

  def blank_audit_value?(val)
    val.nil? || (val.respond_to?(:empty?) && val.empty?)
  end
end

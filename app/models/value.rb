class Value < ApplicationRecord
  audited

  belongs_to :field
  belongs_to :table
  belongs_to :todo, optional: true
  belongs_to :user

  scope :records_at, ->(i) { where(record_index: i) }
end

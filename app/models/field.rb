class Field < ApplicationRecord
  audited

  belongs_to :table
  has_many :values, dependent: :destroy

  validates_presence_of :name
  validates_presence_of :datatype

  enum :datatype, %i[texte nombre euros date oui_non? liste]

end

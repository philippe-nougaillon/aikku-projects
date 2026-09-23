class Todo < ApplicationRecord
  include Sortable::Model
  include LogConcern

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  audited


  acts_as_taggable

  belongs_to :todolist
  belongs_to :user

  has_one :project, through: :todolist

  has_one_attached :document

  has_many :comments, dependent: :destroy
  has_many :values, dependent: :destroy

  validates :name, presence: true

  scope :done, -> {where(done:true)} 
  scope :undone, -> {where(done:false)} 

  sortable :name, :duedate
  sortable :project, -> { joins(:todolist) }, column: "todolists.project_id"
  sortable :participant, -> { joins(:user) }, column: "users.name"

  def preview_name
    return "" if self.docname.blank?

    if File.extname(self.docname) == ".pdf"
      "/documents/#{self.docfilename}.png"
    else
      "/documents/#{self.docfilename}"
    end
  end

  def fullname
    "#{self.project.name}:#{self.todolist.name}:#{self.name}"
  end

  def project_todolist_name
    "#{self.project.name}:#{self.todolist.name}"
  end

  private

  def slug_candidates
    [SecureRandom.uuid]
  end

end

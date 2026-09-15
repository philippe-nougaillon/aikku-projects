class Log < ApplicationRecord
  belongs_to :project
  belongs_to :todolist, optional: true
  belongs_to :user

  default_scope {order('logs.created_at DESC')} 

  scope :except_comments, -> {where('action_id != 3')}
  scope :documents, -> {where('action_id = 4')}  
end

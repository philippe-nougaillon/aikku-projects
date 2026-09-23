# frozen_string_literal: true

class Project < ApplicationRecord # rubocop:disable Style/Documentation
  include LogConcern
  extend SimpleCalendar

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  audited

  acts_as_taggable

  belongs_to :account

  has_many :todolists, dependent: :destroy
  has_many :todos, through: :todolists
  has_many :comments, through: :todos
  has_many :participants, dependent: :destroy
  has_many :users, through: :participants
  has_many :logs, dependent: :destroy

  validates :name, presence: true
  validates :workflow, presence: true

  default_scope { order('projects.name') }

  def pct_avancee
    if todos.count.zero?
      0
    else
      ((todos.done.count * 100) / todos.count)
    end
  end

  def bar_avancee
    span = "<span id='progress'>#{'.' * (pct_avancee / 10)}</span>"
    span + "<span id='progress_done'>#{'.' * (10 - (pct_avancee / 10))}</span>"
  end

  def last_update
    if logs.any?
      logs.maximum(:created_at)
    else
      Date.today
    end
  end

  def workflow?
    workflow == 1
  end

  def current_todolist
    lists = todolists.reorder(:row).reject(&:done?)
    lists.first
  end

  def daily_logs
    logs.where(created_at: 1.day.ago.beginning_of_day..Time.current.end_of_day).reorder(:created_at)
  end

  def weekly_logs
    logs.where(created_at: 7.days.ago.beginning_of_day..Time.current.end_of_day).reorder(:created_at)
  end

  private

  def slug_candidates
    [SecureRandom.uuid]
  end
end

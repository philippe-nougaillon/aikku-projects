# frozen_string_literal: true

class Todolist < ApplicationRecord # rubocop:disable Style/Documentation
  include LogConcern

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  audited

  belongs_to :project

  has_many :todos, dependent: :destroy
  has_many :logs, dependent: :destroy

  validates :name, presence: true

  def pct_avancee
    return 0 if todos.count.zero?

    ((todos.done.count * 100) / todos.count)
  end

  def done?
    (todos.any? and (todos.done.count == todos.count))
  end

  def name_with_indice
    "#{row} - #{name}"
  end

  def next_todo
    todos = self.todos.reject(&:done)
    todos.first
  end

  def bar_avancee
    span = "<span id='progress'>#{'.' * (pct_avancee / 10)}</span>"
    span + "<span id='progress_done'>#{'.' * (10 - (pct_avancee / 10))}</span>"
  end

  private

  def slug_candidates
    [SecureRandom.uuid]
  end
end

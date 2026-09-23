require 'rails_helper'

RSpec.describe Project, type: :model do
  let(:account) { create_account }
  let(:user) { create_user(account: account) }

  subject(:project) do
    described_class.new(
      account: account,
      name: "Project Beta",
      workflow: 1
    )
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(project).to be_valid
    end

    it "is invalid without a name" do
      project.name = nil
      expect(project).not_to be_valid
      expect(project.errors[:name]).to include("doit être rempli(e)")
    end

    it "is invalid without a workflow" do
      project.workflow = nil
      expect(project).not_to be_valid
      expect(project.errors[:workflow]).to include("doit être rempli(e)")
    end
  end

  describe "friendly_id slug" do
    it "generates a slug automatically on save" do
      project.save!
      expect(project.slug).to be_present
      expect(project.slug).to match(/\A[0-9a-f\-]{36}\z/)
    end
  end

  describe "default scope" do
    it "orders projects alphabetically by name" do
      create_project(account: account, user: user, name: "Zeta Project")
      create_project(account: account, user: user, name: "Alpha Project")
      create_project(account: account, user: user, name: "Middle Project")

      names = described_class.where(account: account).pluck(:name)
      expect(names).to eq(["Alpha Project", "Middle Project", "Zeta Project"])
    end
  end

  describe "associations and dependent destroy" do
    let!(:persisted_project) { create_project(account: account, user: user, name: "Parent Project") }
    let!(:todolist) { create_todolist(project: persisted_project) }
    let!(:todo) { create_todo(todolist: todolist, user: user) }

    it "has many todolists and todos through todolists" do
      expect(persisted_project.todolists).to include(todolist)
      expect(persisted_project.todos).to include(todo)
    end

    it "has many participants and users through participants" do
      expect(persisted_project.users).to include(user)
    end

    it "destroys associated todolists when destroyed" do
      expect { persisted_project.destroy }.to change(Todolist, :count).by(-1)
        .and change(Todo, :count).by(-1)
    end

    it "destroys associated participants when destroyed" do
      expect { persisted_project.destroy }.to change(Participant, :count).by(-1)
    end
  end

  describe "progress methods" do
    let(:persisted_project) { create_project(account: account, user: user) }
    let(:todolist) { create_todolist(project: persisted_project) }

    describe "#pct_avancee" do
      it "returns 0 when there are no todos" do
        expect(persisted_project.pct_avancee).to eq(0)
      end

      it "calculates completion percentage correctly" do
        create_todo(todolist: todolist, user: user)
        todo2 = create_todo(todolist: todolist, user: user)
        todo2.update!(done: true)

        expect(persisted_project.pct_avancee).to eq(50)
      end
    end

    describe "#bar_avancee" do
      it "renders the HTML progress bar matching percentage" do
        expect(persisted_project.bar_avancee).to eq("<span id='progress'></span><span id='progress_done'>..........</span>")
      end
    end
  end

  describe "#workflow?" do
    it "returns true when workflow is 1" do
      project.workflow = 1
      expect(project.workflow?).to be true
    end

    it "returns false when workflow is 0 or other value" do
      project.workflow = 0
      expect(project.workflow?).to be false
    end
  end

  describe "#last_update" do
    let(:persisted_project) { create_project(account: account, user: user) }

    it "returns Date.today when there are no logs" do
      expect(persisted_project.last_update).to eq(Date.today)
    end

    it "returns the maximum log created_at timestamp when logs exist" do
      log_time = 2.days.ago.change(usec: 0)
      Log.create!(project: persisted_project, user: user, description: "Test log", action_id: 1, created_at: log_time)

      expect(persisted_project.last_update.to_i).to eq(log_time.to_i)
    end
  end

  describe "#current_todolist" do
    let(:persisted_project) { create_project(account: account, user: user) }
    let!(:list1) { Todolist.create!(project: persisted_project, name: "List 1", row: 1) }
    let!(:list2) { Todolist.create!(project: persisted_project, name: "List 2", row: 2) }

    it "returns the first undone todolist ordered by row" do
      t1 = create_todo(todolist: list1, user: user)
      t1.update!(done: true)
      create_todo(todolist: list2, user: user)

      # list1 is done, list2 is not
      expect(persisted_project.current_todolist).to eq(list2)
    end

    it "returns nil when all todolists are done" do
      t1 = create_todo(todolist: list1, user: user)
      t1.update!(done: true)
      t2 = create_todo(todolist: list2, user: user)
      t2.update!(done: true)

      expect(persisted_project.current_todolist).to be_nil
    end
  end

  describe "#daily_logs and #weekly_logs" do
    let(:persisted_project) { create_project(account: account, user: user) }

    it "filters logs within respective time frames" do
      today_log = Log.create!(project: persisted_project, user: user, description: "Today", action_id: 1, created_at: Time.current)
      old_log = Log.create!(project: persisted_project, user: user, description: "Old", action_id: 1, created_at: 10.days.ago)

      expect(persisted_project.daily_logs).to include(today_log)
      expect(persisted_project.daily_logs).not_to include(old_log)

      expect(persisted_project.weekly_logs).to include(today_log)
      expect(persisted_project.weekly_logs).not_to include(old_log)
    end
  end
end

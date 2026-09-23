require 'rails_helper'

RSpec.describe LogConcern, type: :model do
  let(:account) { create_account }
  let(:user) { create_user(account: account) }
  let(:project) { create_project(account: account, user: user, name: "Alpha Project") }
  let(:todolist) { create_todolist(project: project, name: "Sprint 1") }
  let(:todo) { create_todo(todolist: todolist, user: user, name: "First Task") }

  describe "#log_changes" do
    before do
      # Avoid sending real emails during concern specs
      allow(Notifier).to receive_message_chain(:update, :deliver_now)
      allow(Notifier).to receive_message_chain(:update_client, :deliver_now)
    end

    context "when adding and editing a project" do
      it "creates a log record for project edits" do
        project.name = "Renamed Project"
        expect {
          project.log_changes(:edit, user.id)
        }.to change(Log, :count).by(1)

        log = Log.first
        expect(log.project_id).to eq(project.id)
        expect(log.action_id).to eq(1) # 1 = edit
        expect(log.description).to include("renommé")
      end
    end

    context "when adding and deleting a todolist" do
      it "creates a log record for todolist creation" do
        new_list = Todolist.new(project: project, name: "New List")
        expect {
          new_list.log_changes(:add, user.id)
        }.to change(Log, :count).by(1)

        log = Log.first
        expect(log.action_id).to eq(0) # 0 = add
        expect(log.todolist_id).to eq(new_list.id)
      end

      it "creates a log record for todolist deletion" do
        expect {
          todolist.log_changes(:delete, user.id)
        }.to change(Log, :count).by(1)

        log = Log.first
        expect(log.action_id).to eq(2) # 2 = delete
        expect(log.description).to include("supprimé")
      end
    end

    context "when editing a todo" do
      it "records completion as 'terminé' when done changes to true" do
        todo.done = true
        expect {
          todo.log_changes(:edit, user.id)
        }.to change(Log, :count).by(1)

        log = Log.first
        expect(log.description).to include("terminé")
      end

      it "records re-opening as 'ré-ouvert' when done changes to false" do
        todo.update_column(:done, true)
        todo.done = false
        expect {
          todo.log_changes(:edit, user.id)
        }.to change(Log, :count).by(1)

        log = Log.first
        expect(log.description).to include("ré-ouvert")
      end
    end

    context "when notifications are configured" do
      it "triggers email notifications if project participants subscribe" do
        project.participants.first.update!(want_notification: true)
        todo.name = "Updated name"

        expect(Notifier).to receive_message_chain(:update, :deliver_now)
        todo.log_changes(:edit, user.id)
      end
    end
  end
end

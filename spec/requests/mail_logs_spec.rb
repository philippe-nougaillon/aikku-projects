require 'rails_helper'

RSpec.describe "/mail_logs", type: :request do
  let(:account) { create_account }
  let(:admin) { create_user(account: account, role: :admin) }
  let(:regular_user) { create_user(account: account, role: :utilisateur) }
  let(:mg_client) { instance_double(Mailgun::Client) }

  before do
    allow(Mailgun::Client).to receive(:new).and_return(mg_client)
    allow(mg_client).to receive(:get).and_return(double(to_h: { "items" => [] }))
  end

  describe "GET /index" do
    context "when unauthenticated" do
      it "redirects to the login page" do
        get mail_logs_url
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when regular user (non-admin)" do
      before { sign_in regular_user }

      it "denies access and redirects" do
        get mail_logs_url
        expect(response).to redirect_to(root_path)
      end
    end

    context "when admin" do
      before { sign_in admin }

      it "renders a successful response" do
        MailLog.create!(account: account, to: "dest@example.com", subject: "Test Mail", message_id: "123")
        get mail_logs_url
        expect(response).to be_successful
      end

      it "filters mail logs by recipient email" do
        MailLog.create!(account: account, to: "dest@example.com", subject: "Test Mail", message_id: "123")
        get mail_logs_url, params: { to: "dest" }
        expect(response).to be_successful
      end
    end
  end
end

require "rails_helper"

RSpec.describe MailLogsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/mail_logs").to route_to("mail_logs#index")
    end

    it "does not route to #new" do
      expect(get: "/mail_logs/new").not_to be_routable
    end

    it "does not route to #show" do
      expect(get: "/mail_logs/1").not_to be_routable
    end

    it "does not route to #edit" do
      expect(get: "/mail_logs/1/edit").not_to be_routable
    end

    it "does not route to #create" do
      expect(post: "/mail_logs").not_to be_routable
    end

    it "does not route to #update" do
      expect(put: "/mail_logs/1").not_to be_routable
      expect(patch: "/mail_logs/1").not_to be_routable
    end

    it "does not route to #destroy" do
      expect(delete: "/mail_logs/1").not_to be_routable
    end
  end
end

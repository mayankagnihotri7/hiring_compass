# frozen_string_literal: true

require "rails_helper"

describe SlackNotifier do
  describe "#notify" do
    let(:webhook_url) { "https://hooks.slack.com/services/xxxx/yyy/zzz" }
    let(:message) { "Test message" }

    it "sends a POST request to the webhook url" do
      mock_response = instance_double(Net::HTTPResponse, code: "200")
      allow_any_instance_of(Net::HTTP).to receive(:request).and_return(mock_response)
      expect_any_instance_of(Net::HTTP).to receive(:request).once

      SlackNotifier.notify(webhook_url, message)
    end

    it "does nothing if webhook_url is blank" do
      expect_any_instance_of(Net::HTTP).not_to receive(:request)

      SlackNotifier.notify("", message)
    end
  end
end

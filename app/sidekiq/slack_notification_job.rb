# frozen_string_literal: true

class SlackNotificationJob
  include Sidekiq::Job

  def perform(webhook_url, message)
    SlackNotifier.notify(webhook_url, message)
  end
end

# frozen_string_literal: true

class SlackNotifier
  def self.notify(webhook_url, message)
    return if webhook_url.blank?

    uri = URI.parse(webhook_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = { text: message }.to_json

    http.request(request)
  end
end

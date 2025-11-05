# frozen_string_literal: true

module AuthHelpers
  def auth_headers(user)
    post "/auth/sign_in", params: { email: user.email, password: "password" }, as: :json

    token_data = response.headers.slice("client", "access-token", "uid")

    {
      "client" => token_data["client"],
      "access-token" => token_data["access-token"],
      "uid" => token_data["uid"],
      "Content-Type" => "application/json"
    }
  end

  def send_request(request_type, url, headers: {}, params: {}, xhr: false)
    case request_type
    when :get
      get url, headers:, params:, xhr:
    when :post
      post url, headers:, params:
    when :put
      put url, headers:, params:
    when :patch
      put url, headers:, params:
    when :delete
      delete url, headers:, params:
    end
  end
end

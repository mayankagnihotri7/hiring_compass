# frozen_string_literal: true

module RateLimitable
  extend ActiveSupport::Concern

  included do
    def rate_limit_key
      current_user&.id || request.ip
    end
  end

  class_methods do
    def rate_limit_create(to:, within:)
      rate_limit to: to, within: within,
        by: -> { rate_limit_key },
        only: :create
    end

    def rate_limit_update(to:, within:)
      rate_limit to: to, within: within,
        by: -> { rate_limit_key },
        only: :update
    end

    def rate_limit_destroy(to:, within:)
      rate_limit to: to, within: within,
        by: -> { rate_limit_key },
        only: :destroy
    end

    def rate_limit_download(to:, within:)
      rate_limit to: to, within: within,
        by: -> { rate_limit_key },
        only: :download
    end
  end
end

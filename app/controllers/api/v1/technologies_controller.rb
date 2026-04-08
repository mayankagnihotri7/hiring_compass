# frozen_string_literal: true

module Api
  module V1
    class TechnologiesController < ApplicationController
      def index
        render json: Technology.all
      end
    end
  end
end

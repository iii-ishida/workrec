# frozen_string_literal: true

require 'dry-struct'
require 'app/errors'
require 'app/models/event'

module Types
  include Dry::Types(:strict)
end

module App
  module WorkService
    class Create
      class Params < Dry::Struct
        attribute :user_id, Types::Strict::String
        attribute :title,   Types::Strict::String
      end

      class Result < Dry::Struct
        attribute :work_id, Types::Strict::String.default('')
      end

      def initialize(repo)
        @repo = repo
      end

      def call(params)
        raise Errors::Forbidden if params.user_id.empty?

        event = Models::Event.for_create_work(params.user_id, params.title)
        @repo.insert(event)
        Result.new(work_id: event.work_id)
      end
    end
  end
end

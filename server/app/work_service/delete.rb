# frozen_string_literal: true

require 'dry-struct'
require 'app/errors'
require 'app/models/event'

module Types
  include Dry::Types(:strict)
end

module App
  module WorkService
    class Delete
      class Params < Dry::Struct
        attribute :work_id, Types::Strict::String
        attribute :user_id, Types::Strict::String
      end

      def initialize(repo)
        @repo = repo
      end

      def call(params)
        raise Errors::Forbidden if params.user_id.empty?

        @repo.transaction do |repo|
          prev_event = repo.find_last_event(params.user_id, params.work_id)

          raise Errors::NotFound unless prev_event
          raise Errors::Forbidden if prev_event.user_id != params.user_id

          event = Models::Event.for_delete_work(prev_event)
          repo.insert(event)
        end
      end
    end
  end
end

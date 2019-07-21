# frozen_string_literal: true

require 'dry-struct'
require 'app/errors'
require 'models/event'
require 'models/work'

module Types
  include Dry::Types(:strict)
end

module App
  module Works
    class Delete
      class Params < Dry::Struct
        attribute :work_id, Types::Strict::String
        attribute :user_id, Types::Strict::String
      end

      def initialize(repo)
        @repo = repo
      end

      def call(params)
        raise ForbiddenError if params.user_id.empty?

        now = Time.now

        @repo.transaction do |repo|
          work = repo.find(Models::Work, params.work_id)

          raise NotFoundError unless work
          raise ForbiddenError if work.user_id != params.user_id

          event_id = Models::Event.new_id
          event = new_event(event_id, work.id, params, now)
          repo.insert(event)

          repo.delete(work)
        end
      end

      private

      def new_event(event_id, work_id, params, timestamp)
        Models::Event.new(
          id: event_id,
          user_id: params.user_id,
          work_id: work_id,
          action: 'delete_work',
          time: nil,
          created_at: timestamp
        )
      end
    end
  end
end

# frozen_string_literal: true

require 'dry-struct'
require 'app/errors'
require 'app/models/event'
require 'app/models/work'

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

        now = Time.now

        @repo.transaction do |repo|
          event_id = Models::Event.new_id
          work_id  = Models::Work.new_id

          event = new_event(event_id, work_id, params, now)
          repo.insert(event)

          work = new_work(work_id, event_id, params, now)
          repo.insert(work)

          Result.new(work_id: work_id)
        end
      end

      private

      def new_event(event_id, work_id, params, timestamp)
        Models::Event.new(
          id: event_id,
          user_id: params.user_id,
          work_id: work_id,
          action: 'create_work',
          title: params.title,
          time: nil,
          created_at: timestamp
        )
      end

      def new_work(work_id, event_id, params, timestamp)
        Models::Work.new(
          id: work_id,
          event_id: event_id,
          user_id: params.user_id,
          title: params.title,
          state: 'unstarted',
          updated_at: timestamp
        )
      end
    end
  end
end

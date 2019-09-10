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
    class Update
      class Params < Dry::Struct
        attribute :work_id, Types::Strict::String
        attribute :user_id, Types::Strict::String
        attribute :title,   Types::Strict::String
      end

      def initialize(repo)
        @repo = repo
      end

      def call(params)
        raise Errors::Forbidden if params.user_id.empty?

        now = Time.now

        @repo.transaction do |repo|
          work = repo.find(Models::Work, params.work_id)

          raise Errors::NotFound unless work
          raise Errors::Forbidden if work.user_id != params.user_id

          event_id = Models::Event.new_id
          event = new_event(event_id, work.id, params, now)
          repo.insert(event)

          work = updated_work(work, event_id, params, now)
          repo.update(work)
        end
      end

      private

      def new_event(event_id, work_id, params, timestamp)
        Models::Event.new(
          id: event_id,
          user_id: params.user_id,
          work_id: work_id,
          action: 'update_work',
          title: params.title,
          time: nil,
          created_at: timestamp
        )
      end

      def updated_work(work, event_id, params, timestamp)
        work.patch(event_id: event_id, title: params.title, updated_at: timestamp)
      end
    end
  end
end

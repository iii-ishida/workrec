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
    module ChangeState
      class Params < Dry::Struct
        attribute :user_id, Types::Strict::String
        attribute :work_id, Types::Strict::String
        attribute :time,    Types::Strict::Time
      end

      def change_state(repo, params, action)
        now = Time.now

        repo.transaction do |repo|
          work = repo.find(Models::Work, params.work_id)

          raise NotFoundError unless work
          raise ForbiddenError if work.user_id != params.user_id

          event_id = Models::Event.new_id

          repo.insert(new_event(event_id, work.id, params, action, now))
          repo.update(updated_work(work, event_id, state_with_action(action), now))
        end
      end

      private

      def new_event(event_id, work_id, params, action, timestamp)
        Models::Event.new(
          id: event_id,
          user_id: params.user_id,
          work_id: work_id,
          action: action,
          time: params.time,
          created_at: timestamp
        )
      end

      def updated_work(work, event_id, state, timestamp)
        work.patch(event_id: event_id, state: state, updated_at: timestamp)
      end

      def state_with_action(action)
        case action
        when Models::EVENT_ACTIONS['start_work']         then Models::WORK_STATES['started']
        when Models::EVENT_ACTIONS['pause_work']         then Models::WORK_STATES['paused']
        when Models::EVENT_ACTIONS['resume_work']        then Models::WORK_STATES['resumed']
        when Models::EVENT_ACTIONS['finish_work']        then Models::WORK_STATES['finished']
        when Models::EVENT_ACTIONS['cancel_finish_work'] then Models::WORK_STATES['paused']
        end
      end
    end
  end
end

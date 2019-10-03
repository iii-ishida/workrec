# frozen_string_literal: true

require 'securerandom'
require 'dry-types'
require 'dry-struct'
require_relative './work_states'

module Types
  include Dry::Types(:strict)
end

module App
  module Models
    class WorkListItem < Dry::Struct
      attribute :id,                  Types::Strict::String.constrained(min_size: 1)
      attribute :user_id,             Types::Strict::String.constrained(min_size: 1)
      attribute :base_working_time,   Types::Strict::Time.default(Time.at(0).freeze)
      attribute :paused_at,           Types::Strict::Time.optional.default(nil)
      attribute :started_at,          Types::Strict::Time.default(Time.at(0).freeze)
      attribute :title,               Types::Strict::String
      attribute :state,               WORK_STATES
      attribute :deleted,             Types::Strict::Bool.default(false)
      attribute :created_at,          Types::Strict::Time
      attribute :updated_at,          Types::Strict::Time

      alias deleted? deleted

      EMPTY = WorkListItem.new(
        id: '-',
        user_id: '-',
        title: '',
        state: WORK_STATES['unknown_state'],
        created_at: Time.at(0).freeze,
        updated_at: Time.at(0).freeze
      )

      def patch(props = {})
        WorkListItem.new(self.to_h.merge(props))
      end
    end

    class WorkList < Dry::Struct
      attribute :works,           Types::Strict::Array.of(Models::WorkListItem)
      attribute :next_page_token, Types::Strict::String
    end
  end
end

# CloudDatastoreRepo
module App
  module Models
    class WorkListItem
      def self.kind_name
        'WorkListItem'
      end

      def to_entity
        require 'google/cloud/datastore'

        entity = Google::Cloud::Datastore::Entity.new
        entity['id']                = id
        entity['user_id']           = user_id
        entity['base_working_time'] = base_working_time
        entity['paused_at']         = paused_at
        entity['started_at']        = started_at
        entity['title']             = title
        entity['state']             = state
        entity['created_at']        = created_at
        entity['updated_at']        = updated_at

        entity
      end

      def self.from_entity(entity)
        return unless entity

        props = entity.properties
        WorkListItem.new(
          id: props['id'],
          user_id: props['user_id'],
          base_working_time: props['base_working_time'],
          paused_at: props['paused_at'],
          started_at: props['started_at'],
          title: props['title'],
          state: props['state'],
          created_at: props['created_at'],
          updated_at: props['updated_at']
        )
      end
    end

    class WorkList
      def self.from_entities(entities)
        WorkList.new(
          works: entities.map { |e| WorkListItem.from_entity(e) },
          next_page_token: entities.cursor.to_s
        )
      end
    end
  end
end

# JSON
module App
  module Models
    class WorkListItem
      require 'json'

      def to_json(*_args)
        JSON.generate(
          id: id,
          user_id: user_id,
          base_working_time: base_working_time&.iso8601,
          paused_at: paused_at&.iso8601,
          started_at: started_at&.iso8601,
          title: title,
          state: state,
          created_at: created_at.iso8601,
          updated_at: updated_at.iso8601
        )
      end
    end

    class WorkList
      def to_json(*_args)
        JSON.generate(
          works: works.map(&:to_json),
          next_page_token: next_page_token
        )
      end
    end
  end
end

# apply_events
module App
  module Models
    class WorkListItem
      def apply_events(events)
        events.reduce(self) { |work, e| work.apply_event(e) }
      end

      def apply_event(event)
        case event.action
        when EVENT_ACTIONS['create_work']   then create(event)
        when EVENT_ACTIONS['update_work']   then update(event)
        when EVENT_ACTIONS['delete_work']   then delete
        when EVENT_ACTIONS['start_work']    then start(event)
        when EVENT_ACTIONS['pause_work']    then pause(event)
        when EVENT_ACTIONS['resume_work']   then resume(event)
        when EVENT_ACTIONS['finish_work']   then finish(event)
        when EVENT_ACTIONS['unfinish_work'] then unfinish(event)
        end
      end

      private

      def create(event)
        WorkListItem.new(
          id: event.work_id,
          user_id: event.user_id,
          title: event.title,
          state: WORK_STATES['unstarted'],
          created_at: event.created_at,
          updated_at: event.created_at
        )
      end

      def update(event)
        patch(
          title: event.title,
          updated_at: event.created_at
        )
      end

      def delete
        patch(deleted: true)
      end

      def start(event)
        patch(
          state: WORK_STATES['started'],
          base_working_time: event.time,
          started_at: event.time,
          updated_at: event.created_at
        )
      end

      def pause(event)
        patch(
          state: WORK_STATES['paused'],
          paused_at: event.time,
          updated_at: event.created_at
        )
      end

      def resume(event)
        patch(
          state: WORK_STATES['resumed'],
          base_working_time: calculate_base_working_time(event.time),
          paused_at: nil,
          updated_at: event.created_at
        )
      end

      def finish(event)
        patch(
          state: WORK_STATES['finished'],
          paused_at: paused? ? paused_at : event.time,
          updated_at: event.created_at
        )
      end

      def unfinish(event)
        patch(
          state: WORK_STATES['paused'],
          updated_at: event.created_at
        )
      end

      def paused?
        state == WORK_STATES['paused']
      end

      def calculate_base_working_time(resumed_at)
        base_working_time + (resumed_at - paused_at)
      end
    end
  end
end

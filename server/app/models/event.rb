# frozen_string_literal: true

require 'securerandom'
require 'dry-types'
require 'dry-struct'

module Types
  include Dry::Types(:strict)
end

module App
  module Models
    EVENT_ACTIONS = Types::Strict::Integer.enum(
      0 => 'unknown',
      1 => 'create_work',
      2 => 'update_work',
      3 => 'delete_work',
      4 => 'start_work',
      5 => 'pause_work',
      6 => 'resume_work',
      7 => 'finish_work',
      8 => 'unfinish_work'
    )

    class Event < Dry::Struct
      attribute :id,          Types::Strict::String.constrained(min_size: 1)
      attribute :prev_id,     Types::Strict::String.default('')
      attribute :user_id,     Types::Strict::String.constrained(min_size: 1)
      attribute :work_id,     Types::Strict::String.constrained(min_size: 1)
      attribute :action,      EVENT_ACTIONS
      attribute :title,       Types::Strict::String.default('')
      attribute :time,        Types::Strict::Time.optional
      attribute :created_at,  Types::Strict::Time

      def self.new_id
        SecureRandom.uuid
      end

      def self.kind_name
        'Event'
      end

      def to_entity
        require 'google/cloud/datastore'

        entity = Google::Cloud::Datastore::Entity.new
        entity['id']         = id
        entity['prev_id']    = prev_id
        entity['user_id']    = user_id
        entity['work_id']    = work_id
        entity['action']     = action
        entity['title']      = title
        entity['time']       = time
        entity['created_at'] = created_at

        entity
      end

      def self.from_entity(entity)
        return unless entity

        props = entity.properties
        Event.new(
          id: props['id'],
          prev_id: props['prev_id'],
          user_id: props['user_id'],
          work_id: props['work_id'],
          action: props['action'],
          title: props['title'],
          time: props['time'],
          created_at: props['created_at']
        )
      end
    end
  end
end

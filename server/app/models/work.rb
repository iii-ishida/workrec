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
    class Work < Dry::Struct
      attribute :id,          Types::Strict::String.constrained(min_size: 1)
      attribute :user_id,     Types::Strict::String.constrained(min_size: 1)
      attribute :event_id,    Types::Strict::String.constrained(min_size: 1)
      attribute :title,       Types::Strict::String
      attribute :state,       WORK_STATES
      attribute :updated_at,  Types::Strict::Time

      def self.new_id
        SecureRandom.uuid
      end

      def patch(props = {})
        Work.new(self.to_h.merge(props))
      end
    end
  end
end

# CloudDatastoreRepository
module App
  module Models
    class Work
      def self.kind_name
        'CommandWork'
      end

      def to_entity
        require 'google/cloud/datastore'

        entity = Google::Cloud::Datastore::Entity.new
        entity['id']         = id
        entity['user_id']    = user_id
        entity['event_id']   = event_id
        entity['title']      = title
        entity['state']      = state
        entity['updated_at'] = updated_at

        entity
      end

      def self.from_entity(entity)
        return unless entity

        props = entity.properties
        Work.new(
          id: props['id'],
          user_id: props['user_id'],
          event_id: props['event_id'],
          title: props['title'],
          state: props['state'],
          updated_at: props['updated_at']
        )
      end
    end
  end
end

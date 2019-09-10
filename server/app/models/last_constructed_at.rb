# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module Types
  include Dry::Types(:strict)
end

module App
  module Models
    class LastConstructedAt < Dry::Struct
      attribute :id,          Types::Strict::String.constrained(min_size: 1)
      attribute :user_id,     Types::Strict::String.constrained(min_size: 1)
      attribute :time,        Types::Strict::Time

      def self.new_id(user_id)
        user_id.dup
      end

      def self.kind_name
        'LastConstructedAt'
      end

      def to_entity
        require 'google/cloud/datastore'

        entity = Google::Cloud::Datastore::Entity.new
        entity['id']      = id
        entity['user_id'] = user_id
        entity['time']    = time

        entity
      end

      def self.from_entity(entity)
        return unless entity

        props = entity.properties
        LastConstructedAt.new(
          id: props['id'],
          user_id: props['user_id'],
          time: props['time']
        )
      end
    end
  end
end

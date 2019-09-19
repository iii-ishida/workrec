# frozen_string_literal: true

require 'dry-struct'
require 'app/errors'
require 'app/models/event'

module Types
  include Dry::Types(:strict)
end

module App
  module WorkService
    module ChangeState
      class Params < Dry::Struct
        attribute :user_id, Types::Strict::String
        attribute :work_id, Types::Strict::String
        attribute :time,    Types::Strict::Time
      end

      def change_state(repo, params, action)
        repo.transaction do |repo|
          prev_event = repo.find_last_event(params.user_id, params.work_id)

          raise Errors::NotFound unless prev_event

          event = Models::Event.for_change_work_state(prev_event, action, params.time)
          repo.insert(event)
        end
      end
    end
  end
end

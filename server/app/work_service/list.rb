# frozen_string_literal: true

require 'dry-struct'
require 'app/errors'
require 'app/models/event'
require 'app/models/worklist'
require 'app/models/last_constructed_at'

module Types
  include Dry::Types(:strict)
end

module App
  module WorkService
    class List
      class Params < Dry::Struct
        attribute :user_id,     Types::Strict::String
        attribute :page_size,   Types::Strict::Integer
        attribute :page_token,  Types::Strict::String
      end

      class Result < Dry::Struct
        attribute :work_list, Models::WorkList
      end

      def initialize(repo)
        @repo = repo
      end

      def call(params)
        raise Errors::Forbidden if params.user_id.empty?

        construct_worklist(@repo, params.user_id)
        work_list = @repo.list_works(params.user_id, params.page_size, params.page_token)
        Result.new(work_list: work_list)
      end

      private

      def construct_worklist(repo, user_id)
        repo.transaction do |tx|
          id = Models::LastConstructedAt.new_id(user_id)
          constructed_at = tx.find(Models::LastConstructedAt, id)

          events = repo.list_events(user_id, constructed_at&.time || Time.at(0))
          break if events.empty?

          apply_events(tx, events)

          constructed_at = Models::LastConstructedAt.new(
            id: id,
            user_id: user_id,
            time: events.last.created_at
          )
          tx.upsert(constructed_at)
        end
      end

      def apply_events(tx_repo, events)
        grouped = events.group_by(&:work_id)
        grouped.each do |work_id, events_of_work|
          work = tx_repo.find(Models::WorkListItem, work_id) || Models::WorkListItem::EMPTY
          work = work.apply_events(events_of_work)

          if work.deleted?
            tx_repo.delete(work)
          else
            tx_repo.upsert(work)
          end
        end
      end
    end
  end
end

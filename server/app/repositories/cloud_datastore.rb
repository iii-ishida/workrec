# frozen_string_literal: true

require 'google/cloud/datastore'
require_relative './env'

module App
  module Repositories
    class CloudDatastore
      def initialize(datastore = Google::Cloud::Datastore.new(project_id: Repo::Env::PROJECT_ID))
        @datastore = datastore
      end

      def transaction
        ret = nil
        err = nil

        @datastore.transaction do |tx|
          ret = yield CloudDatastore.new(tx)
        rescue StandardError => e
          err = e
          raise e
        end

        ret
      rescue Google::Cloud::Datastore::TransactionError => e
        raise err || e
      end

      def find(klass, id)
        entity = @datastore.find(klass.kind_name, id)
        klass.from_entity(entity)
      end

      def insert(model)
        entity = model.to_entity
        entity.key = @datastore.key(model.class.kind_name, model.id)
        @datastore.insert entity
      end

      def upsert(model)
        entity = model.to_entity
        entity.key = @datastore.key(model.class.kind_name, model.id)
        @datastore.save entity
      end

      def update(model)
        entity = model.to_entity
        entity.key = @datastore.key(model.class.kind_name, model.id)
        @datastore.update entity
      end

      def delete(model)
        key = @datastore.key(model.class.kind_name, model.id)
        @datastore.delete key
      end

      def list_events(user_id, created_at, page_size = 100, page_token = '')
        require './app/models/event'

        query = Google::Cloud::Datastore::Query.new
        query.kind(Models::Event.kind_name)
             .where('user_id', '=', user_id)
             .where('created_at', '>', created_at)
             .order('user_id')
             .order('created_at')
             .limit(page_size)
             .start(page_token)

        events = @datastore.run query
        events.map { |e| Models::Event.from_entity(e) }
      end

      def find_last_event(user_id, work_id)
        require './app/models/event'

        query = @datastore.query(Models::Event.kind_name)
                          .where('user_id', '=', user_id)
                          .where('work_id', '=', work_id)
                          .order('user_id')
                          .order('work_id')
                          .order('created_at', :desc)
                          .limit(1)

        events = @datastore.run query
        Models::Event.from_entity(events.first)
      end

      def list_works(user_id, page_size, page_token)
        require './app/models/worklist'

        query = Google::Cloud::Datastore::Query.new
        query.kind(Models::WorkListItem.kind_name)
             .where('user_id', '=', user_id)
             .order('user_id')
             .order('created_at', :desc)
             .limit(page_size)
             .start(page_token)

        works = @datastore.run query

        Models::WorkList.from_entities(works)
      end
    end
  end
end

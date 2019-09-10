# frozen_string_literal: true

require 'app/work_service/create'
require 'app/work_service/delete'
require 'web/auth'

module Web
  module Works
    class Delete
      def initialize(repo)
        @repo = repo
      end

      def call(work_id, req)
        user_id = Web::Auth.get_user_id(req)

        params = new_params(user_id, work_id)
        App::WorkService::Delete.new(@repo).call(params)

        [200]
      rescue App::Errors::NotFound
        [404]
      rescue App::Errors::Forbidden => e
        logger = Logger.new(STDOUT)
        logger.warn(e)
        [404]
      end

      private

      def new_params(user_id, work_id)
        App::WorkService::Delete::Params.new(user_id: user_id, work_id: work_id)
      end
    end
  end
end

# frozen_string_literal: true

require 'app/work_service/start'
require 'web/auth'

module Web
  module Works
    class Start
      def initialize(repo)
        @repo = repo
      end

      def call(work_id, req)
        user_id = Web::Auth.get_user_id(req)

        params = new_params(user_id, work_id, req)
        App::WorkService::Start.new(@repo).call(params)

        [200]
      rescue App::Errors::NotFound
        [404]
      rescue App::Errors::Forbidden => e
        logger = Logger.new(STDOUT)
        logger.warn(e)
        [404]
      end

      private

      def new_params(user_id, work_id, req)
        require 'json'

        param = JSON.parse(req.body.read)
        App::WorkService::Start::Params.new(user_id: user_id, work_id: work_id, time: Time.iso8601(param['time']))
      end
    end
  end
end

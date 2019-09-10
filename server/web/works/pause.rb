# frozen_string_literal: true

require 'app/work_service/pause'
require 'web/auth'

module Web
  module Works
    class Pause
      require 'pb/time_pb'
      using TimePb

      def initialize(repo)
        @repo = repo
      end

      def call(work_id, req)
        user_id = Web::Auth.get_user_id(req)

        params = new_params(user_id, work_id, req)
        App::WorkService::Pause.new(@repo).call(params)

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
        require 'google/protobuf'
        require 'pb/command_request_pb'

        param = ChangeWorkStateRequestPb.decode(req.body.read)
        App::WorkService::Pause::Params.new(user_id: user_id, work_id: work_id, time: param.time.to_time)
      end
    end
  end
end

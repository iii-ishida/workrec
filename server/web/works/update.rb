# frozen_string_literal: true

require 'app/works/update'
require 'web/auth'

module Web
  module Works
    class Update
      def initialize(repo)
        @repo = repo
      end

      def call(work_id, req)
        user_id = Web::Auth.get_user_id(req)

        params = new_params(user_id, work_id, req)
        App::Works::Update.new(@repo).call(params)

        [200]
      rescue App::NotFoundError
        [404]
      rescue App::ForbiddenError => e
        logger = Logger.new(STDOUT)
        logger.warn(e)
        [404]
      end

      private

      def new_params(user_id, work_id, req)
        require 'google/protobuf'
        require 'pb/command_request_pb'

        param = UpdateWorkRequestPb.decode(req.body.read)
        App::Works::Update::Params.new(user_id: user_id, work_id: work_id, title: param.title)
      end
    end
  end
end

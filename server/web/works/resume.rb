# frozen_string_literal: true

require 'app/works/resume'
require 'web/auth'

module Web
  module Works
    class Resume
      def initialize(repo)
        @repo = repo
      end

      def call(work_id, req)
        user_id = Web::Auth.get_user_id(req)

        params = App::Works::Resume::Params.new(user_id: user_id, work_id: work_id, time: Time.now)
        App::Works::Resume.new(@repo).call(params)

        [200]
      rescue App::NotFoundError
        [404]
      rescue App::ForbiddenError => e
        logger = Logger.new(STDOUT)
        logger.warn(e)
        [404]
      end
    end
  end
end

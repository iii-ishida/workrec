# frozen_string_literal: true

require 'app/works/create'
require 'web/env'
require 'web/auth'

module Web
  module Works
    class Create
      def initialize(repo)
        @repo = repo
      end

      def call(req)
        user_id = Web::Auth.get_user_id(req)

        params = new_params(user_id, req)
        ret = App::Works::Create.new(@repo).call(params)

        [201, {'Location' => "#{Web::Env::API_ORIGIN}/#{Web::Env::API_VERSION}/works/#{ret.work_id}"}]
      rescue App::ForbiddenError
        [401]
      end

      private

      def new_params(user_id, req)
        require 'google/protobuf'
        require 'pb/command_request_pb'

        param = CreateWorkRequestPb.decode(req.body.read)
        App::Works::Create::Params.new(user_id: user_id, title: param.title)
      end
    end
  end
end

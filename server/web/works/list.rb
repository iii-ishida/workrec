# frozen_string_literal: true

require 'app/work_service/list'
require 'web/auth'

module Web
  module Works
    class List
      def initialize(repo)
        @repo = repo
      end

      def call(req)
        user_id = Web::Auth.get_user_id(req)

        params = new_params(user_id, req)
        ret = App::WorkService::List.new(@repo).call(params)

        [200, {'Content-Type' => 'application/octet-stream'}, ret.work_list.to_pb]
      rescue App::Errors::Forbidden
        [401]
      end

      private

      def new_params(user_id, req)
        page_size, page_token = req.params.values_at('page_size', 'page_token')
        App::WorkService::List::Params.new(user_id: user_id, page_size: page_size || 100, page_token: page_token || '')
      end
    end
  end
end

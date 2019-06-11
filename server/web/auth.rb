# frozen_string_literal: true

require 'logger'
require 'libs/firebase_auth'

module Web
  module Auth
    module_function

    def get_user_id(req)
      auth = req.get_header('HTTP_AUTHORIZATION')
      id_token = auth.to_s.split(' ')[1].to_s
      return '' if id_token.empty?

      begin
        FirebaseAuth.new(Web::Env::PROJECT_ID).verify_id_token(id_token)
      rescue StandardError => e
        Logger.new(STDOUT).warn(e)
        ''
      end
    end
  end
end

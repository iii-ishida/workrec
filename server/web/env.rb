# frozen_string_literal: true

module Web
  module Env
    PROJECT_ID = ENV['GOOGLE_CLOUD_PROJECT']
    API_ORIGIN = ENV['API_ORIGIN'] || 'localhost:8080'
    CLIENT_ORIGIN = ENV['CLIENT_ORIGIN'] || 'localhost:3000'
    API_VERSION = 'v1'
  end
end

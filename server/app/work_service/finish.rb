# frozen_string_literal: true

require 'app/models/event'
require_relative './change_state'

module App
  module WorkService
    class Finish
      include ChangeState

      def initialize(repo)
        @repo = repo
      end

      def call(params)
        change_state(@repo, params, Models::EVENT_ACTIONS['finish_work'])
      end
    end
  end
end

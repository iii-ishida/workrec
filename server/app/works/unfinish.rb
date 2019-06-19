# frozen_string_literal: true

require 'models/event'
require_relative './change_state'

module App
  module Works
    class Unfinish
      include ChangeState

      def initialize(repo)
        @repo = repo
      end

      def call(params)
        change_state(@repo, params, Models::EVENT_ACTIONS['unfinish_work'])
      end
    end
  end
end

# frozen_string_literal: true

require 'models/event'
require_relative './change_state'

module App
  module Works
    class Resume
      include ChangeState

      def initialize(repo)
        @repo = repo
      end

      def call(params)
        change_state(@repo, params, Event::Actions['resume_work'])
      end
    end
  end
end

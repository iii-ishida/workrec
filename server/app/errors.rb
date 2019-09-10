# frozen_string_literal: true

module App
  module Errors
    class NotFound < StandardError; end
    class Forbidden < StandardError; end
  end
end

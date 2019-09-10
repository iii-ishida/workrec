# frozen_string_literal: true

$LOAD_PATH.push(__dir__)

require 'web/router'
run Web::Router.freeze.app

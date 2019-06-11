# frozen_string_literal: true

require 'dry-types'

module Types
  include Dry::Types(:strict)
end

module Models
  WORK_STATES = Types::Strict::Integer.enum(
    0 => 'unknown_state',
    1 => 'unstarted',
    2 => 'started',
    3 => 'paused',
    4 => 'resumed',
    5 => 'finished'
  )

  module_function

  def work_states_to_pb(state)
    require 'google/protobuf'
    require 'pb/worklist_pb'

    case state
    when WORK_STATES['unknown_state'] then WorkListItemPb::State_UNSPECIFIED
    when WORK_STATES['unstarted']     then WorkListItemPb::State::UNSTARTED
    when WORK_STATES['started']       then WorkListItemPb::State::STARTED
    when WORK_STATES['paused']        then WorkListItemPb::State::PAUSED
    when WORK_STATES['resumed']       then WorkListItemPb::State::RESUMED
    when WORK_STATES['finishe']       then WorkListItemPb::State::FINISHED
    end
  end
end

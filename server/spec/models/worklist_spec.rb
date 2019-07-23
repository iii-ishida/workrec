# frozen_string_literal: true

RSpec.describe Models::WorkList do
  describe '#to_entity' do
  end

  describe '.from_entity' do
  end

  describe '#to_pb' do
  end
end


RSpec.describe Models::WorkListItem do
  describe '#apply_events' do
    let(:user_id) { 'some-user-id' }
    let(:work_id) { 'some-work-id' }
    let(:title) { 'some-title' }

    let(:create_work_event) { Models::Event.new(id: 'event-01', user_id: user_id, work_id: work_id, action: 'create_work', title: title, time: nil, created_at: Time.now) }
    let(:start_work_event) { Models::Event.new(id: 'event-02', user_id: user_id, work_id: work_id, action: 'start_work', title: '', time: Time.now + 1 * 60, created_at: Time.now + 1) }
    let(:pause_work_event) { Models::Event.new(id: 'event-03', user_id: user_id, work_id: work_id, action: 'pause_work', title: '', time: Time.now + 2 * 60, created_at: Time.now + 2) }
    let(:resume_work_event) { Models::Event.new(id: 'event-04', user_id: user_id, work_id: work_id, action: 'resume_work', title: '', time: Time.now + 3 * 60, created_at: Time.now + 3) }

    let(:created_work) do
      Models::WorkListItem.new(
        id: work_id,
        user_id: user_id,
        base_working_time: Time.at(0),
        paused_at: nil,
        started_at: Time.at(0),
        title: title,
        state: 'unstarted',
        deleted: false,
        created_at: create_work_event.created_at,
        updated_at: create_work_event.created_at
      )
    end
    let(:started_work) do
      created_work.patch(
        state: 'started',
        base_working_time: start_work_event.time,
        started_at: start_work_event.time,
        updated_at: start_work_event.created_at
      )
    end
    let(:paused_work) do
      created_work.patch(
        state: 'paused',
        base_working_time: start_work_event.time,
        started_at: start_work_event.time,
        paused_at: pause_work_event.time,
        updated_at: pause_work_event.created_at
      )
    end
    let(:resumed_work) do
      created_work.patch(
        state: 'resumed',
        base_working_time: start_work_event.time + 1 * 60,
        started_at: start_work_event.time,
        paused_at: nil,
        updated_at: resume_work_event.created_at
      )
    end

    context 'create work' do
      it 'returns the applied WorkListItem' do
        Timecop.freeze(Time.now) do
          expect(Models::WorkListItem::EMPTY.apply_events([create_work_event])).to eq(created_work)
        end
      end
    end

    context 'start work' do
      it 'returns the applied WorkListItem' do
        Timecop.freeze(Time.now) do
          expect(created_work.apply_events([start_work_event])).to eq(started_work)
        end
      end
    end

    context 'pause work' do
      it 'returns the applied WorkListItem' do
        Timecop.freeze(Time.now) do
          expect(started_work.apply_events([pause_work_event])).to eq(paused_work)
        end
      end
    end

    context 'resume work' do
      it 'returns the applied WorkListItem' do
        Timecop.freeze(Time.now) do
          expect(paused_work.apply_events([resume_work_event])).to eq(resumed_work)
        end
      end
    end
  end
end

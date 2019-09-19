# frozen_string_literal: true

RSpec.describe App::WorkService::Update do
  describe '#call' do
    subject(:update_work) do
      repo_out_of_tran = instance_double(App::Repositories::CloudDatastore)
      allow(repo_out_of_tran).to receive(:transaction).and_yield(repo)
      described_class.new(repo_out_of_tran)
    end

    let(:repo) do
      repo = instance_double(App::Repositories::CloudDatastore, insert: nil, update: nil)
      allow(repo).to receive(:find_last_event).with(user_id, work_id).and_return(prev_event)
      repo
    end

    let(:user_id) { 'some-user-id' }
    let(:prev_event_id) { 'some-prev-event-id' }
    let(:event_id) { 'some-event-id' }
    let(:work_id) { 'some-work-id' }
    let(:params) { App::WorkService::Update::Params.new(user_id: user_id, work_id: work_id, title: 'updated title') }
    let(:prev_event) do
      App::Models::Event.new(
        id: prev_event_id,
        user_id: user_id,
        work_id: work_id,
        action: 'create_work',
        title: 'some title',
        time: nil,
        created_at: Time.now - 60 * 60
      )
    end

    let(:event_for_update_work) do
      App::Models::Event.new(
        id: event_id,
        prev_id: prev_event_id,
        user_id: user_id,
        work_id: work_id,
        action: 'update_work',
        title: params.title,
        time: nil,
        created_at: Time.now
      )
    end

    before do
      allow(App::Models::Event).to receive(:for_update_work).and_return(event_for_update_work)
    end

    it 'save event and work', :aggregate_failures do
      Timecop.freeze(Time.now) do
        update_work.call(params)

        expect(repo).to have_received(:insert).with(event_for_update_work)
      end
    end

    context 'when work_id not found in repo' do
      let(:repo) do
        repo = instance_double(App::Repositories::CloudDatastore)
        allow(repo).to receive(:find_last_event).with(user_id, work_id).and_return(nil)
        repo
      end

      it 'raise App::Errors::NotFound' do
        expect { update_work.call(params) }.to raise_error(App::Errors::NotFound)
      end
    end

    context 'when user_id is empty' do
      let(:params) { App::WorkService::Update::Params.new(user_id: '', work_id: work_id, title: 'updated-title') }

      it 'raise App::Errors::Forbidden' do
        expect { update_work.call(params) }.to raise_error(App::Errors::Forbidden)
      end
    end
  end
end

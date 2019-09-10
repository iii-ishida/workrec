# frozen_string_literal: true

RSpec.describe App::WorkService::Create do
  describe '#call' do
    subject(:create_work) do
      repo_out_of_tran = instance_double(App::Repositories::CloudDatastore)
      allow(repo_out_of_tran).to receive(:transaction).and_yield(repo)
      described_class.new(repo_out_of_tran)
    end

    let(:repo) { instance_double(App::Repositories::CloudDatastore, insert: nil) }
    let(:user_id) { 'some-user-id' }
    let(:event_id) { 'some-event-id' }
    let(:work_id) { 'some-work-id' }
    let(:params) { App::WorkService::Create::Params.new(user_id: user_id, title: 'some-title') }

    let(:new_event) do
      App::Models::Event.new(
        id: event_id,
        user_id: user_id,
        work_id: work_id,
        action: 'create_work',
        title: params.title,
        time: nil,
        created_at: Time.now
      )
    end
    let(:new_work) do
      App::Models::Work.new(
        id: work_id,
        user_id: user_id,
        event_id: event_id,
        title: params.title,
        state: 'unstarted',
        updated_at: Time.now
      )
    end

    let(:result) { App::WorkService::Create::Result.new(work_id: work_id) }

    before do
      allow(App::Models::Event).to receive(:new_id).and_return(event_id)
      allow(App::Models::Work).to receive(:new_id).and_return(work_id)
    end

    it 'save event and work', :aggregate_failures do
      Timecop.freeze(Time.now) do
        create_work.call(params)

        expect(repo).to have_received(:insert).with(new_event)
        expect(repo).to have_received(:insert).with(new_work)
      end
    end

    it 'return created work id' do
      expect(create_work.call(params)).to eq(result)
    end

    context 'when user_id is empty' do
      let(:params) { App::WorkService::Create::Params.new(user_id: '', title: 'some-title') }

      it 'raise App::Errors::Forbidden' do
        expect { create_work.call(params) }.to raise_error(App::Errors::Forbidden)
      end
    end
  end
end

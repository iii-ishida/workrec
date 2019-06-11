# frozen_string_literal: true

RSpec.describe App::Works::Create do
  describe '#call' do
    subject(:create_work) do
      repo_out_of_tran = instance_double(CloudDatastoreRepository)
      allow(repo_out_of_tran).to receive(:transaction).and_yield(repo)
      described_class.new(repo_out_of_tran)
    end

    let(:repo) { instance_double(CloudDatastoreRepository, insert: nil) }
    let(:user_id) { 'some-user-id' }
    let(:event_id) { 'some-event-id' }
    let(:work_id) { 'some-work-id' }
    let(:params) { App::Works::Create::Params.new(user_id: user_id, title: 'some-title') }

    let(:new_event) do
      Models::Event.new(
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
      Models::Work.new(
        id: work_id,
        user_id: user_id,
        event_id: event_id,
        title: params.title,
        state: 'unstarted',
        updated_at: Time.now
      )
    end

    let(:result) { App::Works::Create::Result.new(work_id: work_id) }

    before do
      allow(Models::Event).to receive(:new_id).and_return(event_id)
      allow(Models::Work).to receive(:new_id).and_return(work_id)
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
      let(:params) { App::Works::Create::Params.new(user_id: '', title: 'some-title') }

      it 'raise App::Works::ForbiddenError' do
        expect { create_work.call(params) }.to raise_error(App::ForbiddenError)
      end
    end
  end
end

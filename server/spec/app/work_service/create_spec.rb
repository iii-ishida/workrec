# frozen_string_literal: true

RSpec.describe App::WorkService::Create do
  describe '#call' do
    subject(:create) do
      described_class.new(repo)
    end

    let(:repo) { instance_double(App::Repositories::CloudDatastore, insert: nil) }
    let(:user_id) { 'some-user-id' }
    let(:work_id) { 'some-work-id' }
    let(:params) { App::WorkService::Create::Params.new(user_id: user_id, title: 'some-title') }

    let(:event_for_create_work) do
      App::Models::Event.new(
        id: 'some-event-id',
        user_id: user_id,
        work_id: work_id,
        action: 'create_work',
        title: params.title,
        time: nil,
        created_at: Time.now
      )
    end

    let(:result) { App::WorkService::Create::Result.new(work_id: work_id) }

    before do
      allow(App::Models::Event).to receive(:for_create_work).and_return(event_for_create_work)
    end

    it 'save an event' do
      Timecop.freeze(Time.now) do
        create.call(params)

        expect(repo).to have_received(:insert).with(event_for_create_work)
      end
    end

    it 'return created work id' do
      expect(create.call(params)).to eq(result)
    end

    context 'when user_id is empty' do
      let(:params) { App::WorkService::Create::Params.new(user_id: '', title: 'some-title') }

      it 'raise App::Errors::Forbidden' do
        expect { create.call(params) }.to raise_error(App::Errors::Forbidden)
      end
    end
  end
end

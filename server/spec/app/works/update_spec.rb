# frozen_string_literal: true

RSpec.describe App::Works::Update do
  describe '#call' do
    subject(:update_work) do
      repo_out_of_tran = instance_double(CloudDatastoreRepository)
      allow(repo_out_of_tran).to receive(:transaction).and_yield(repo)
      described_class.new(repo_out_of_tran)
    end

    let(:repo) do
      repo = instance_double(CloudDatastoreRepository, insert: nil, update: nil)
      allow(repo).to receive(:find).with(Models::Work, work_id).and_return(source_work)
      repo
    end
    let(:user_id) { 'some-user-id' }
    let(:event_id) { 'some-event-id' }
    let(:work_id) { 'some-work-id' }
    let(:params) { App::Works::Update::Params.new(user_id: user_id, work_id: work_id, title: 'updated-title') }
    let(:new_event) do
      Models::Event.new(
        id: event_id,
        user_id: user_id,
        work_id: work_id,
        action: 'update_work',
        title: params.title,
        time: nil,
        created_at: Time.now
      )
    end
    let(:source_work) do
      Models::Work.new(
        id: work_id,
        user_id: user_id,
        event_id: 'prev-event-id',
        title: 'some-title',
        state: 'unstarted',
        updated_at: Time.now - 60 * 60
      )
    end
    let(:updated_work) do
      Models::Work.new(
        id: work_id,
        user_id: user_id,
        event_id: event_id,
        title: params.title,
        state: 'unstarted',
        updated_at: Time.now
      )
    end

    before do
      allow(Models::Event).to receive(:new_id).and_return(event_id)
    end

    it 'save event and work', :aggregate_failures do
      Timecop.freeze(Time.now) do
        update_work.call(params)

        expect(repo).to have_received(:insert).with(new_event)
        expect(repo).to have_received(:update).with(updated_work)
      end
    end

    context 'when work_id not found in repo' do
      let(:repo) do
        repo = instance_double(CloudDatastoreRepository)
        allow(repo).to receive(:find).with(Models::Work, work_id).and_return(nil)
        repo
      end

      it 'raise App::Works::NotFoundError' do
        expect { update_work.call(params) }.to raise_error(App::NotFoundError)
      end
    end

    context 'when user_id is empty' do
      let(:params) { App::Works::Update::Params.new(user_id: '', work_id: work_id, title: 'updated-title') }

      it 'raise App::Works::ForbiddenError' do
        expect { update_work.call(params) }.to raise_error(App::ForbiddenError)
      end
    end

    context 'when params.user_id is not work.user_id' do
      let(:params) { App::Works::Update::Params.new(user_id: 'other-user-id', work_id: work_id, title: 'updated-title') }

      it 'raise App::Works::ForbiddenError' do
        expect { update_work.call(params) }.to raise_error(App::ForbiddenError)
      end
    end
  end
end

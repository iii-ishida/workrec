# frozen_string_literal: true

require 'rack/test'

OUTER_APP = Rack::Builder.new.run Web::Router.freeze.app

RSpec.describe Web::Router do
  include Rack::Test::Methods

  def app
    OUTER_APP
  end

  let(:list_work)     { instance_double(Web::Works::List,         call: [200]) }
  let(:create_work)   { instance_double(Web::Works::Create,       call: [200]) }
  let(:update_work)   { instance_double(Web::Works::Update,       call: [200]) }
  let(:delete_work)   { instance_double(Web::Works::Delete,       call: [200]) }
  let(:start_work)    { instance_double(Web::Works::Start,        call: [200]) }
  let(:pause_work)    { instance_double(Web::Works::Pause,        call: [200]) }
  let(:resume_work)   { instance_double(Web::Works::Resume,       call: [200]) }
  let(:finish_work)   { instance_double(Web::Works::Finish,       call: [200]) }
  let(:unfinish_work) { instance_double(Web::Works::Unfinish, call: [200]) }

  let(:work_id) { 'some-work-id' }

  before do
    allow(CloudDatastoreRepository).to receive(:new)
    allow(Web::Works::List).to receive(:new).and_return(list_work)
    allow(Web::Works::Create).to receive(:new).and_return(create_work)
    allow(Web::Works::Update).to receive(:new).and_return(update_work)
    allow(Web::Works::Delete).to receive(:new).and_return(delete_work)
    allow(Web::Works::Start).to receive(:new).and_return(start_work)
    allow(Web::Works::Pause).to receive(:new).and_return(pause_work)
    allow(Web::Works::Resume).to receive(:new).and_return(resume_work)
    allow(Web::Works::Finish).to receive(:new).and_return(finish_work)
    allow(Web::Works::Unfinish).to receive(:new).and_return(unfinish_work)
  end

  context 'when OPTIONS /v1/works' do
    let(:allow_methods) { %w[GET POST PATCH DELETE OPTIONS] }
    let(:allow_headers) { %w[Content-Type Authorization] }
    let(:allow_max_age) { '600' }

    it 'set Access-Control-Allow-Methods header' do
      options '/v1/works'
      expect(last_response.header['Access-Control-Allow-Methods'].split(',')).to match_array(allow_methods)
    end

    it 'set Access-Control-Allow-Headers header' do
      options '/v1/works'
      expect(last_response.header['Access-Control-Allow-Headers'].split(',')).to match_array(allow_headers)
    end

    it 'set Access-Control-Max-Age header' do
      options '/v1/works'
      expect(last_response.header['Access-Control-Max-Age']).to be(allow_max_age)
    end
  end

  context 'when GET /v1/works' do
    it 'do Web::Works::List#call' do
      get '/v1/works'
      expect(list_work).to have_received(:call).with(Web::Router::RodaRequest)
    end
  end

  context 'when POST /v1/works' do
    it 'do Web::Works::Create#call' do
      post '/v1/works'
      expect(create_work).to have_received(:call).with(Web::Router::RodaRequest)
    end
  end

  context 'when PATCH /v1/works/{work_id}' do
    it 'do Web::Works::Update#call with work_id' do
      patch "/v1/works/#{work_id}"
      expect(update_work).to have_received(:call).with(work_id, Web::Router::RodaRequest)
    end
  end

  context 'when DELETE /v1/works/{work_id}' do
    it 'do Web::Works::Delete#call with work_id' do
      delete "/v1/works/#{work_id}"
      expect(delete_work).to have_received(:call).with(work_id, Web::Router::RodaRequest)
    end
  end

  context 'when POST /v1/works/{work_id}/start' do
    it 'do Web::Works::Start#call with work_id' do
      post "/v1/works/#{work_id}/start"
      expect(start_work).to have_received(:call).with(work_id, Web::Router::RodaRequest)
    end
  end

  context 'when POST /v1/works/{work_id}/pause' do
    it 'do Web::Works::Pause#call with work_id' do
      post "/v1/works/#{work_id}/pause"
      expect(pause_work).to have_received(:call).with(work_id, Web::Router::RodaRequest)
    end
  end

  context 'when POST /v1/works/{work_id}/resume' do
    it 'do Web::Works::Resume#call with work_id' do
      post "/v1/works/#{work_id}/resume"
      expect(resume_work).to have_received(:call).with(work_id, Web::Router::RodaRequest)
    end
  end

  context 'when POST /v1/works/{work_id}/finish' do
    it 'do Web::Works::Finish#call with work_id' do
      post "/v1/works/#{work_id}/finish"
      expect(finish_work).to have_received(:call).with(work_id, Web::Router::RodaRequest)
    end
  end

  context 'when POST /v1/works/{work_id}/unfinish' do
    it 'do Web::Works::Unfinish#call with work_id' do
      post "/v1/works/#{work_id}/unfinish"
      expect(unfinish_work).to have_received(:call).with(work_id, Web::Router::RodaRequest)
    end
  end
end

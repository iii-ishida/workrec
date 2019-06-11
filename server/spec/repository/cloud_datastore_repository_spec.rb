# frozen_string_literal: true

require 'google/cloud/datastore'

class Google::Cloud::Datastore::Entity
  def ==(other)
    self_properties = self.properties.to_h
    other_properties = other.properties.to_h

    return false if self_properties.size != other_properties.size

    self_properties.all? { |k, v| other_properties[k] == v }
  end

  def eql?(other)
    self == other
  end

  def hash
    self.properties.to_h.hash
  end
end

class Google::Cloud::Datastore::Query
  def ==(other)
    self.to_grpc == other.to_grpc
  end

  def eql?(other)
    self == other
  end

  def hash
    self.to_grpc.hash
  end
end

RSpec.describe CloudDatastoreRepository do
  subject(:repo) { described_class.new(datastore) }

  let(:datastore) do
    datastore = instance_double(Google::Cloud::Datastore::Dataset)
    allow(datastore).to receive(:transaction)
    allow(datastore).to receive(:find).and_return(entity)
    allow(datastore).to receive(:insert)
    allow(datastore).to receive(:update)
    allow(datastore).to receive(:save)
    allow(datastore).to receive(:delete)
    allow(datastore).to receive(:run).and_return(Google::Cloud::Datastore::Dataset::QueryResults.new)
    allow(datastore).to receive(:key).and_return(key)
    datastore
  end

  let(:user_id) { 'some-user-id' }
  let(:id) { 'some-model-id' }
  let(:key) { 'some-entity-key' }
  let(:model) { Models::Work.new(id: id, user_id: user_id, event_id: 'some-event-id', title: 'some title', state: 'unstarted', updated_at: Time.now) }
  let(:entity) do
    e = model.to_entity
    e.key = key
    e
  end
  let(:created_at) { Time.now }
  let(:default_page_size) { 100 }
  let(:default_page_token) { '' }

  describe '#transaction' do
    it 'do datastore#transaction' do
      repo.transaction { |arg| }
      expect(datastore).to have_received(:transaction)
    end
  end

  describe '#find' do
    it 'do datastore#find with kind_name and id' do
      repo.find(Models::Work, id)
      expect(datastore).to have_received(:find).with(Models::Work.kind_name, id)
    end

    it 'returns the model for the given id' do
      expect(repo.find(Models::Work, id)).to eq(model)
    end
  end

  describe '#insert' do
    it 'do datastore#insert with the entity' do
      repo.insert(model)
      expect(datastore).to have_received(:insert).with(entity)
    end
  end

  describe '#upsert' do
    it 'do datastore#save with the entity' do
      repo.upsert(model)
      expect(datastore).to have_received(:save).with(entity)
    end
  end

  describe '#update' do
    it 'do datastore#update with the entity' do
      repo.update(model)
      expect(datastore).to have_received(:update).with(entity)
    end
  end

  describe '#delete' do
    it 'do datastore#delete with the key' do
      repo.delete(model)
      expect(datastore).to have_received(:delete).with(key)
    end
  end

  describe '#list_events' do
    let(:list_events_query) do
      Google::Cloud::Datastore::Query.new
                                     .kind(Models::Event.kind_name)
                                     .where('user_id', '=', user_id)
                                     .where('created_at', '>', created_at)
                                     .order('user_id')
                                     .order('created_at')
                                     .limit(default_page_size)
                                     .start(default_page_token)
    end

    it 'do datastore#run with the query for events' do
      Timecop.freeze(Time.now) do
        repo.list_events(user_id, created_at)
        expect(datastore).to have_received(:run).with(list_events_query)
      end
    end

    it 'returns the models' do
    end
  end

  describe '#list_works' do
    let(:page_size) { 200 }
    let(:page_token) { 'some-page-token' }
    let(:list_works_query) do
      Google::Cloud::Datastore::Query.new
                                     .kind(Models::WorkListItem.kind_name)
                                     .where('user_id', '=', user_id)
                                     .order('user_id')
                                     .order('created_at', :desc)
                                     .limit(page_size)
                                     .start(page_token)
    end

    it 'do datastore#run with the query for works' do
      Timecop.freeze(Time.now) do
        repo.list_works(user_id, page_size, page_token)
        expect(datastore).to have_received(:run).with(list_works_query)
      end
    end

    it 'returns the models' do
    end
  end
end

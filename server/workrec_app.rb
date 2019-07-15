# frozen_string_literal: true

require 'roda'
require 'web/works'
require 'web/env'
require 'repository/cloud_datastore_repository'

class WorkrecApp < Roda
  plugin :all_verbs
  plugin :default_headers, 'Access-Control-Allow-Origin' => Web::Env::CLIENT_ORIGIN

  logger = Logger.new(STDOUT)

  route do |r|
    r.on 'v1' do
      r.on 'works' do
        r.options do
          response['Access-Control-Allow-Methods'] = %w[GET POST PATCH DELETE OPTIONS].join(',')
          response['Access-Control-Allow-Headers'] = %w[Content-Type Authorization].join(',')
          response['Access-Control-Max-Age'] = '600'
        end

        r.is do
          r.get do
            respond *Web::Works::List.new(CloudDatastoreRepository.new).call(r)
          end

          r.post do
            respond *Web::Works::Create.new(CloudDatastoreRepository.new).call(r)
          end
        end

        # /v1/works/:work_id
        r.on String do |work_id|
          r.is do
            r.get do
            end

            r.patch do
               respond *Web::Works::Update.new(CloudDatastoreRepository.new).call(work_id, r)
            end

            r.delete do
              respond *Web::Works::Delete.new(CloudDatastoreRepository.new).call(work_id, r)
            end
          end

          r.post 'start'  do
            respond *Web::Works::Start.new(CloudDatastoreRepository.new).call(work_id, r)
          end

          r.post 'pause' do
            respond *Web::Works::Pause.new(CloudDatastoreRepository.new).call(work_id, r)
          end

          r.post 'resume' do
            respond *Web::Works::Resume.new(CloudDatastoreRepository.new).call(work_id, r)
          end

          r.post 'finish' do
            respond *Web::Works::Finish.new(CloudDatastoreRepository.new).call(work_id, r)
          end

          r.post 'unfinish' do
            respond *Web::Works::Unfinish.new(CloudDatastoreRepository.new).call(work_id, r)
          end
        end
      end
    end
  rescue => e
    logger.error(e)
    respond 500
  end

  private

  def respond(status, header = {}, body = nil)
    response.status = status
    header.each { |k, v| response[k] = v }
    response.write(body) if body
  end
end


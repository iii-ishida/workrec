# frozen_string_literal: true

require 'jwt'
require 'json'
require 'net/https'
require 'openssl'
require 'uri'

class FirebaseAuth
  def initialize(project_id)
    raise 'project_id is empty' if project_id.to_s.empty?

    @project_id = project_id
  end

  def verify_id_token(id_token)
    now = Time.now

    certs = FirebaseCerts.fetch
    payload = get_payload(id_token, certs)

    auth_time = payload.fetch('auth_time').to_i
    raise "auth_time claim is invalid: '#{auth_time}'" if Time.at(auth_time) > now

    sub = payload.fetch('sub').to_s
    raise "sub (subject) claim is invalid: '#{sub}'" if sub.empty? || sub.size > 128

    sub
  end

  private

  def get_payload(id_token, certs)
    _, header = JWT.decode(id_token, nil, false)

    kid = header.fetch('kid')
    cert = certs.fetch(kid)
    rsa_public = OpenSSL::X509::Certificate.new(cert).public_key
    options = {
      algorithm: 'RS256',
      iss: "https://securetoken.google.com/#{@project_id}",
      aud: @project_id,
      verify_iss: true,
      verify_aud: true,
      verify_iat: true
    }

    payload, _header = JWT.decode(id_token, rsa_public, true, options)

    payload
  end
end

module FirebaseCerts
  CERTS_URI = URI.parse('https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com').freeze
  private_constant :CERTS_URI

  @expire_at = Time.new(0)
  @certs = {}

  module_function

  def fetch
    now = Time.now

    return @certs if @expire_at > now

    @certs, @expire_at = get_certs(CERTS_URI, now)
    @certs
  end

  # private

  def get_certs(uri, now)
    header, body = get_uri(uri)
    max_age = header['cache-control'].to_s[/max-age=([0-9]+)/, 1]
    expire_at = now + max_age.to_i
    certs = JSON.parse(body)

    [certs, expire_at]
  end

  def get_uri(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'

    header, body = http.start do
      res = http.get(uri.path)
      [res, res.body]
    end

    # rails exception unless 2xx
    header.value

    [header, body]
  end

  private_class_method :get_certs, :get_uri
end

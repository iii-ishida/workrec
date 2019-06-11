# frozen_string_literal: true

RSpec.describe FirebaseAuth do
  describe '#new' do
    context 'when project_id is empty' do
      it 'raise exception' do
        expect { described_class.new('') }.to raise_error(StandardError)
      end
    end
  end

  describe '#verify_id_token' do
    subject(:auth) { described_class.new(project_id) }

    let(:project_id) { 'some-project-id' }
    let(:id_token) { 'some-id-token' }
    let(:kid) { 'some-kid' }
    let(:decoded_token) { [{}, {'alg' => 'RS256', 'kid' => kid, 'typ' => 'JWT'}] }
    let(:certs) { {kid => 'some-cert', 'other-kid' => 'other-cert'} }
    let(:certificate) { instance_double(OpenSSL::X509::Certificate, public_key: OpenSSL::PKey::RSA.generate(2048)) }
    let(:sub) { 'some-sub' }
    let(:auth_time) { Time.now - 1 }

    before do
      allow(JWT).to receive(:decode).with(String, nil, false).and_return(decoded_token)
      allow(JWT).to receive(:decode).with(String, OpenSSL::PKey::RSA, true, Hash).and_return([{'sub' => sub, 'auth_time' => auth_time}, nil])
      allow(FirebaseCerts).to receive(:fetch).and_return(certs)
      allow(OpenSSL::X509::Certificate).to receive(:new).and_return(certificate)
    end

    it "do OpenSSL::X509::Certificate#new with the cert correspond to the token's kid" do
      auth.verify_id_token(id_token)
      expect(OpenSSL::X509::Certificate).to have_received(:new).with(certs[kid])
    end

    it 'do JWT#decode with id_token, public_key, true, and options' do
      options = {
        algorithm: 'RS256',
        iss: "https://securetoken.google.com/#{project_id}",
        aud: project_id,
        verify_iss: true,
        verify_aud: true,
        verify_iat: true
      }

      auth.verify_id_token(id_token)
      expect(JWT).to have_received(:decode).with(id_token, OpenSSL::PKey::RSA, true, options)
    end

    it "returns token's sub" do
      expect(auth.verify_id_token(id_token)).to be(sub)
    end

    context('when auth_time is not in the past') do
      let(:auth_time) { Time.now + 60 }

      it 'raise exception' do
        Timecop.freeze(Time.now) do
          expect { auth.verify_id_token(id_token) }.to raise_error(StandardError)
        end
      end
    end
  end
end

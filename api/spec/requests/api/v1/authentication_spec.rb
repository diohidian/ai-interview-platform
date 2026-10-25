# frozen_string_literal: true

require 'rails_helper'

# TEST FOR SIGNUP
RSpec.describe 'POST /api/v1/auth/signup', type: :request do
  describe 'successful signup' do
    it 'creates a user account that awaits admin approval' do
      email = "signup-#{SecureRandom.hex(8)}@example.com"

      expect do
        post '/api/v1/auth/signup',
             params: { email: email, password: 'StrongPassword123!', role: 'admin' },
             as: :json
      end.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body.dig('user', 'email')).to eq(email)
      expect(response.parsed_body.dig('user', 'role')).to eq('user')
      expect(response.parsed_body).not_to have_key('token')
    end
  end

  describe 'invalid signup' do
    it 'rejects an invalid email without creating an account' do
      expect do
        post '/api/v1/auth/signup',
             params: { email: 'not-an-email', password: 'StrongPassword123!' },
             as: :json
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body.dig('errors', 0, 'message')).to be_present
    end
  end
end

RSpec.describe 'POST /api/v1/auth/login', type: :request do
  let(:password) { 'StrongPassword123!' }
  let(:scheme) { 'test-corp' }

  describe 'successful login' do
    it 'returns a token for an admin user' do
      user = User.create!(
        email: "admin-#{SecureRandom.hex(8)}@example.com",
        password: password,
        role: 'admin'
      )

      post '/api/v1/auth/login',
           params: { email: user.email, password: password },
           headers: { 'X-Tenant-Scheme' => scheme },
           as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig('user', 'id')).to eq(user.id)
      expect(response.parsed_body.dig('user', 'email')).to eq(user.email)
      expect(response.parsed_body.dig('user', 'role')).to eq('admin')
      expect(JsonWebToken.decode(response.parsed_body.fetch('token'))).to include(
        'user_id' => user.id,
        'role' => 'admin',
        'scheme' => scheme
      )
    end
  end

  describe 'invalid login' do
    it 'rejects an incorrect password' do
      user = User.create!(
        email: "admin-#{SecureRandom.hex(8)}@example.com",
        password: password,
        role: 'admin'
      )

      post '/api/v1/auth/login',
           params: { email: user.email, password: 'WrongPassword123!' },
           as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body.dig('errors', 0, 'message')).to eq('Invalid email or password')
    end

    it 'does not allow a non-admin user to log in' do
      user = User.create!(
        email: "user-#{SecureRandom.hex(8)}@example.com",
        password: password,
        role: 'user'
      )

      post '/api/v1/auth/login',
           params: { email: user.email, password: password },
           as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body.dig('errors', 0, 'message')).to eq('Invalid email or password')
    end
  end
end
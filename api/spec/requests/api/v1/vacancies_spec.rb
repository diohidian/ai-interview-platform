# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'POST /api/v1/vacancies', type: :request do
  let(:scheme) { 'test-corp' }
  let(:tenant_id) { 987_654 }
  let(:auth_headers) do
    token = JsonWebToken.encode(user_id: 42, role: 'admin', scheme: scheme)
    {
      'Authorization' => "Bearer #{token}",
      'X-Tenant-Scheme' => scheme
    }
  end

  before do
    organization = instance_double(Organization, id: tenant_id)
    allow(Organization).to receive(:identify).with(scheme).and_return(organization)
  end

  it 'creates a vacancy for the authenticated assessor' do
    expect do
      post '/api/v1/vacancies',
           params: {
             vacancy: {
               role_title: 'Senior Backend Engineer',
               culture_dimensions: 'Collaborative',
               competency_expectations: 'System design and API development'
             }
           },
           headers: auth_headers,
           as: :json
    end.to change(Vacancy, :count).by(1)

    expect(response).to have_http_status(:created)
    expect(response.parsed_body.dig('vacancy', 'role_title')).to eq('Senior Backend Engineer')
    expect(response.parsed_body.dig('vacancy', 'created_by')).to eq(42)
  end

  it 'rejects a vacancy without a role title' do
    expect do
      post '/api/v1/vacancies',
           params: { vacancy: { role_title: '' } },
           headers: auth_headers,
           as: :json
    end.not_to change(Vacancy, :count)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.parsed_body.dig('errors', 0, 'message')).to be_present
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'POST /api/v1/assessments', type: :request do
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
    allow(SystemPromptGeneratorWorker).to receive(:perform_async)
  end

  it 'creates an assessment and queues system prompt generation' do
    expect do
      post '/api/v1/assessments',
           params: { assessment: { name: 'Backend Engineer', time_limit_min: 45, language: 'en' } },
           headers: auth_headers,
           as: :json
    end.to change(Assessment, :count).by(1)

    expect(response).to have_http_status(:created)
    expect(response.parsed_body.dig('assessment', 'name')).to eq('Backend Engineer')
    expect(response.parsed_body.dig('assessment', 'created_by')).to eq(42)
    expect(response.parsed_body['system_prompt_generated']).to be(true)
    expect(SystemPromptGeneratorWorker).to have_received(:perform_async)
      .with(response.parsed_body.dig('assessment', 'id'))
  end

  it 'rejects a time limit that is not supported' do
    expect do
      post '/api/v1/assessments',
           params: { assessment: { name: 'Backend Engineer', time_limit_min: 15 } },
           headers: auth_headers,
           as: :json
    end.not_to change(Assessment, :count)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.parsed_body.dig('errors', 0, 'message')).to be_present
    expect(SystemPromptGeneratorWorker).not_to have_received(:perform_async)
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DELETE /api/v1/assessments/:assessment_id/sessions/:id', type: :request do
  let(:scheme) { 'test-corp' }
  let(:tenant_id) { 987_654 }
  let(:assessment) do
    Assessment.create!(
      name: 'Backend Engineer',
      time_limit_min: 30,
      created_by: 42,
      tenant_id: tenant_id
    )
  end
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
    allow(AudioWebSocketMiddleware).to receive(:close_session_connections).and_return(true)
  end

  it 'deletes a pending candidate invite' do
    session = assessment.sessions.create!(tenant_id: tenant_id, candidate_name: 'Candidate A')

    expect do
      delete "/api/v1/assessments/#{assessment.id}/sessions/#{session.id}",
             headers: auth_headers,
             as: :json
    end.to change(Session, :count).by(-1)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['message']).to eq('Candidate and interview data deleted')
  end

  it 'deletes an active interview after closing its live connection' do
    session = assessment.sessions.create!(
      tenant_id: tenant_id,
      candidate_name: 'Candidate B',
      status: 'active'
    )

    expect do
      delete "/api/v1/assessments/#{assessment.id}/sessions/#{session.id}",
             headers: auth_headers,
             as: :json
    end.to change(Session, :count).by(-1)

    expect(AudioWebSocketMiddleware).to have_received(:close_session_connections).with(session.id)
    expect(response).to have_http_status(:ok)
  end

  it 'deletes an ended interview and its portfolio data' do
    session = assessment.sessions.create!(
      tenant_id: tenant_id,
      candidate_name: 'Candidate C',
      status: 'ended',
      end_reason: 'manual_candidate'
    )
    portfolio = session.create_portfolio!(generation_status: 'complete')

    expect do
      delete "/api/v1/assessments/#{assessment.id}/sessions/#{session.id}",
             headers: auth_headers,
             as: :json
    end.to change(Session, :count).by(-1)
      .and change(Portfolio, :count).by(-1)

    expect(response).to have_http_status(:ok)
    expect(Portfolio.find_by(id: portfolio.id)).to be_nil
  end
end

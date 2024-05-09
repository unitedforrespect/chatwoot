require 'rails_helper'

RSpec.describe 'Linear Integration API', type: :request do
  let(:account) { create(:account) }
  let(:user) { create(:user) }
  let(:api_key) { 'valid_api_key' }
  let(:agent) { create(:user, account: account, role: :agent) }
  let(:processor_service) { instance_double(Integrations::Linear::ProcessorService) }

  before do
    create(:integrations_hook, :linear, account: account)
    allow(Integrations::Linear::ProcessorService).to receive(:new).with(account: account).and_return(processor_service)
  end

  describe 'GET /api/v1/accounts/:account_id/integrations/linear/teams' do
    context 'when it is an authenticated user' do
      context 'when data is retrieved successfully' do
        let(:teams_data) { [{ 'id' => 'team1', 'name' => 'Team One' }] }

        it 'returns team data' do
          allow(processor_service).to receive(:teams).and_return(teams_data)
          get "/api/v1/accounts/#{account.id}/integrations/linear/teams",
              headers: agent.create_new_auth_token,
              as: :json
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('Team One')
        end
      end

      context 'when data retrieval fails' do
        it 'returns error message' do
          allow(processor_service).to receive(:teams).and_return(error: 'error message')
          get "/api/v1/accounts/#{account.id}/integrations/linear/teams",
              headers: agent.create_new_auth_token,
              as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('error message')
        end
      end
    end
  end

  describe 'GET /api/v1/accounts/:account_id/integrations/linear/team_entites' do
    let(:team_id) { 'team1' }

    context 'when it is an authenticated user' do
      context 'when data is retrieved successfully' do
        let(:team_entities_data) do
          {
            users: [{ 'id' => 'user1', 'name' => 'User One' }],
            projects: [{ 'id' => 'project1', 'name' => 'Project One' }],
            states: [{ 'id' => 'state1', 'name' => 'State One' }],
            labels: [{ 'id' => 'label1', 'name' => 'Label One' }]
          }
        end

        it 'returns team entities data' do
          allow(processor_service).to receive(:team_entites).with(team_id).and_return(team_entities_data)
          get "/api/v1/accounts/#{account.id}/integrations/linear/team_entites",
              params: { team_id: team_id },
              headers: agent.create_new_auth_token,
              as: :json
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('User One')
          expect(response.body).to include('Project One')
          expect(response.body).to include('State One')
          expect(response.body).to include('Label One')
        end
      end

      context 'when data retrieval fails' do
        it 'returns error message' do
          allow(processor_service).to receive(:team_entites).with(team_id).and_return(error: 'error message')
          get "/api/v1/accounts/#{account.id}/integrations/linear/team_entites",
              params: { team_id: team_id },
              headers: agent.create_new_auth_token,
              as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('error message')
        end
      end
    end
  end

  describe 'POST /api/v1/accounts/:account_id/integrations/linear/create_issue' do
    let(:issue_params) do
      {
        team_id: 'team1',
        title: 'Sample Issue',
        description: 'This is a sample issue.',
        assignee_id: 'user1',
        priority: 'high',
        label_ids: ['label1']
      }
    end

    context 'when it is an authenticated user' do
      context 'when the issue is created successfully' do
        let(:created_issue) { { 'id' => 'issue1', 'title' => 'Sample Issue' } }

        it 'returns the created issue' do
          allow(processor_service).to receive(:create_issue).with(issue_params.stringify_keys).and_return(created_issue)
          post "/api/v1/accounts/#{account.id}/integrations/linear/create_issue",
               params: issue_params,
               headers: agent.create_new_auth_token,
               as: :json
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('Sample Issue')
        end
      end

      context 'when issue creation fails' do
        it 'returns error message' do
          allow(processor_service).to receive(:create_issue).with(issue_params.stringify_keys).and_return(error: 'error message')
          post "/api/v1/accounts/#{account.id}/integrations/linear/create_issue",
               params: issue_params,
               headers: agent.create_new_auth_token,
               as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('error message')
        end
      end
    end
  end

  describe 'POST /api/v1/accounts/:account_id/integrations/linear/link_issue' do
    let(:link) { 'https://linear.app/issue1' }
    let(:issue_id) { 'issue1' }

    context 'when it is an authenticated user' do
      context 'when the issue is linked successfully' do
        let(:linked_issue) { { 'id' => 'issue1', 'link' => 'https://linear.app/issue1' } }

        it 'returns the linked issue' do
          allow(processor_service).to receive(:link_issue).with(link, issue_id).and_return(linked_issue)
          post "/api/v1/accounts/#{account.id}/integrations/linear/link_issue",
               params: { link: link, issue_id: issue_id },
               headers: agent.create_new_auth_token,
               as: :json
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('https://linear.app/issue1')
        end
      end

      context 'when issue linking fails' do
        it 'returns error message' do
          allow(processor_service).to receive(:link_issue).with(link, issue_id).and_return(error: 'error message')
          post "/api/v1/accounts/#{account.id}/integrations/linear/link_issue",
               params: { link: link, issue_id: issue_id },
               headers: agent.create_new_auth_token,
               as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('error message')
        end
      end
    end
  end
end

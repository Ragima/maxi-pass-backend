# # frozen_string_literal: true
#
# require 'acceptance_helper'
#
# RSpec.resource 'Users / TokenValidationsController' do
#   header 'Accept', 'application/json'
#   header 'Content-Type', 'application/json'
#   get '/auth/validate_token' do
#     context '200' do
#       authentication :apiKey, :access_token, name: 'access-token'
#       authentication :apiKey, :client_id, name: 'client'
#       authentication :apiKey, :uid, name: 'uid'
#       let(:access_token) { request_headers['access-token'] }
#       let(:client_id) { request_headers['client'] }
#       let(:uid) { request_headers['uid'] }
#       let(:request_headers) { combined_auth_headers create :user }
#       let(:raw_post) { params.to_json }
#
#       example_request 'GET validate_token 200. Check session validity by headers' do
#         expect(status).to eq(200)
#       end
#     end
#
#     context '401' do
#       example_request 'GET validate_token 401' do
#         expect(status).to eq(401)
#       end
#     end
#   end
# end

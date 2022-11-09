# # frozen_string_literal: true
#
# require 'acceptance_helper'
#
# RSpec.resource 'Contents / VaultItemsController' do
#   header 'Accept', 'application/json'
#   header 'Content-Type', 'application/json'
#
#   before do
#     allow_any_instance_of(Encoder).to receive(:decrypted_content)
#       .and_return(
#         'web_address' => 'admin.socialtrading.uat.pp.ua',
#         'username' => 'dforbf@gmail.com',
#         'password' => '123456',
#         'change_password_page' => nil,
#         'login_page' => nil,
#         'password_field' => nil,
#         'login_field' => nil
#                                                       )
#     user_vault
#   end
#
#   get '/vault_items' do
#     authentication :apiKey, :access_token, name: 'access-token'
#     authentication :apiKey, :client_id, name: 'client'
#     authentication :apiKey, :uid, name: 'uid'
#     authentication :apiKey, :master_key, name: 'master-key'
#     let(:current_user) { create :user }
#     let(:access_token) { request_headers['access-token'] }
#     let(:client_id) { request_headers['client'] }
#     let(:uid) { request_headers['uid'] }
#     let(:request_headers) { combined_auth_headers current_user }
#     let(:master_key) { current_user.master_key }
#     let(:vault) { create :vault }
#     let(:vault_item) { create :login_item, vault: vault}
#     let(:user_vault) { create :user_vault, vault: vault, user: current_user }
#     let(:raw_post) { params.to_json }
#
#     context 'with 200' do
#       before do
#         vault_item
#       end
#       example_request 'GET index 200' do
#         expect(status).to eq(200)
#       end
#     end
#   end
#
#   get '/vault_items/:id' do
#     authentication :apiKey, :access_token, name: 'access-token'
#     authentication :apiKey, :client_id, name: 'client'
#     authentication :apiKey, :uid, name: 'uid'
#     authentication :apiKey, :master_key, name: 'master-key'
#     let(:current_user) { create :user }
#     let(:access_token) { request_headers['access-token'] }
#     let(:client_id) { request_headers['client'] }
#     let(:uid) { request_headers['uid'] }
#     let(:master_key) { current_user.master_key }
#     let(:request_headers) { combined_auth_headers current_user }
#     let(:vault) { create :vault }
#     let(:vault_item) { create :login_item, vault: vault}
#     let(:user_vault) { create :user_vault, vault: vault, user: current_user }
#     let(:raw_post) { params.to_json }
#
#     context 'with 200' do
#       let(:id) { vault_item.to_param }
#       example_request 'GET show 200' do
#         expect(status).to eq(200)
#       end
#     end
#   end
# end

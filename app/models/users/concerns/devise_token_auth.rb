# frozen_string_literal: true

require 'bcrypt'

module Users::Concerns::DeviseTokenAuth
  extend ActiveSupport::Concern
  include DeviseTokenAuth::Concerns::User

  included do
    def email_provider?
      false
    end

    def email_required?
      false
    end

    def email_changed?
      false
    end

    def will_save_change_to_email?
      false
    end
  end

  def create_token(client_id: nil, token: nil, expiry: nil, **token_extras)
    client_id ||= SecureRandom.urlsafe_base64(nil, false)
    token     ||= SecureRandom.urlsafe_base64(nil, false)
    expiry    ||= (Time.zone.now + token_lifespan).to_i

    tokens[client_id] = {
      token: BCrypt::Password.create(token),
      expiry: expiry
    }.merge!(token_extras)

    clean_old_tokens

    [client_id, token, expiry]
  end

  def create_new_auth_token(client_id = nil)
    now = Time.zone.now

    client_id, token = create_token(
      client_id: client_id,
      expiry: (now + token_lifespan).to_i,
      session_key: tokens.fetch(client_id, {})['session_key'],
      last_token: tokens.fetch(client_id, {})['token'],
      updated_at: now
    )

    update_auth_header(token, client_id)
  end

  def build_auth_header(token, client_id = 'default')
    # client may use expiry to prevent validation request if expired
    # must be cast as string or headers will break
    expiry = tokens[client_id]['expiry'] || tokens[client_id][:expiry]
    headers =
      {
        DeviseTokenAuth.headers_names[:"access-token"] => token,
        DeviseTokenAuth.headers_names[:"token-type"] => 'Bearer',
        DeviseTokenAuth.headers_names[:client] => client_id,
        DeviseTokenAuth.headers_names[:expiry] => expiry.to_s,
        DeviseTokenAuth.headers_names[:uid] => uid
      }
    headers['master-key'] = master_key unless master_key.nil?
    headers
  end
end

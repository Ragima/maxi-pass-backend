# frozen_string_literal: true

module AuthHelper
  def combined_auth_headers(user)
    return nil if user.nil?

    user.generate_master_key
    session_key = user.generate_session_key
    user.create_token(session_key: session_key)
    user.save
    user.create_new_auth_token(user.tokens.keys.first).merge('master-key': user.master_key)
  end
end

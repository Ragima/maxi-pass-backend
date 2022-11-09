module KeysConcern
  extend ActiveSupport::Concern

  def decrypt_temp_phrase
    @decrypt_temp_phrase ||= @current_user.decrypt_session_key(master_key, session_key)
  end

  def master_key
    @master_key ||= request.headers['master-key']
  end

  def session_key
    @current_user.tokens.fetch(@client_id, {}).fetch('session_key')
  end
end
# frozen_string_literal: true

module UsersHelper
  def create_user(entity_sym, params_hash = {})
    user = create entity_sym, params_hash

    encoder = Encoder.new(user)
    rsa_key = encoder.generate_user_private_key
    public_key = rsa_key.public_key.to_pem
    private_key = encoder.encrypt_user_private_key(user, user.temp_phrase, rsa_key)

    user.public_key = public_key
    user.private_key = private_key
    user.save
    user
  end
end
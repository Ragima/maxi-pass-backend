# frozen_string_literal: true

# frozen_string_literal

module ComplicatedKeyGenerator
  def complicated_key
    generate_complicated_key(temp_phrase, make_salt, make_iter, 32, make_digest)
  end

  def generate_complicated_key(phrase, salt, iter, key_len, key)
    OpenSSL::PKCS5.pbkdf2_hmac(phrase, salt, iter, key_len, key)
  end

  private

  def make_salt
    created_at.to_s * 10
  end

  def make_iter
    20_000
  end

  def make_digest
    OpenSSL::Digest::SHA256.new
  end
end

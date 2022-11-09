# frozen_string_literal: true

module Cipher
  def encrypt_key(complicated_key, phrase)
    cipher = generate_cipher
    cipher.encrypt
    cipher.key = complicated_key
    cipher.update(phrase) + cipher.final
  end

  def decrypt_key(complicated_key, phrase)
    decipher = generate_cipher
    decipher.decrypt
    decipher.key = complicated_key
    decipher.update(phrase) + decipher.final
  end

  private

  def generate_cipher
    OpenSSL::Cipher::AES256.new :CBC
  end
end

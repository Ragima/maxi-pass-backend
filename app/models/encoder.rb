# frozen_string_literal: true

require 'openssl'
require 'base64'

class Encoder
  include Users::Concerns::Role
  attr_reader :current_user

  def initialize(current_user)
    @current_user = current_user
  end

  def generate_user_private_key
    OpenSSL::PKey::RSA.new(2048)
  end

  def encrypt_user_private_key(user, pass_phrase, user_private_key_to_encrypt)
    cipher = OpenSSL::Cipher.new 'AES-256-CBC'
    cipher.encrypt
    salt = user.created_at.to_s * 10
    iter = 20_000
    key_len = cipher.key_len
    digest = OpenSSL::Digest::SHA256.new
    key = OpenSSL::PKCS5.pbkdf2_hmac(pass_phrase, salt, iter, key_len, digest)
    cipher.key = key
    encrypted = cipher.update(user_private_key_to_encrypt.to_pem)
    encrypted << cipher.final
    Base64.encode64(encrypted)
  end

  def decrypted_current_user_private_key
    pass_phrase = current_user.temp_phrase
    return if pass_phrase.blank?

    cipher = OpenSSL::Cipher.new 'AES-256-CBC'
    cipher.decrypt
    # cipher.iv = iv # the one generated with #random_iv
    salt = current_user.created_at.to_s * 10
    iter = 20_000
    key_len = cipher.key_len
    digest = OpenSSL::Digest::SHA256.new
    key = OpenSSL::PKCS5.pbkdf2_hmac(pass_phrase, salt, iter, key_len, digest)
    cipher.key = key
    encrypted_user_private_key_base64 = current_user.private_key
    return if encrypted_user_private_key_base64.blank?

    encrypted = Base64.decode64(encrypted_user_private_key_base64)
    decrypted_user_private_key = cipher.update encrypted
    decrypted_user_private_key << cipher.final
  end

  # Encrypt, decrypt content

  def encrypt_content(sym_key, content)
    return if sym_key.nil? || content.blank?

    crypt = ActiveSupport::MessageEncryptor.new(sym_key, cipher: 'aes-256-cbc')
    encrypted_content = crypt.encrypt_and_sign(content)
    Base64.encode64(encrypted_content)
  end

  def decrypt_content(decrypted_vault_key, encrypted_content_base64)
    return if decrypted_vault_key.blank? || encrypted_content_base64.blank?

    encrypted_content = Base64.decode64(encrypted_content_base64)
    crypt = ActiveSupport::MessageEncryptor.new(decrypted_vault_key, cipher: 'aes-256-cbc')
    crypt.decrypt_and_verify(encrypted_content)
  end

  # Encrypt, decrypt, generate sym key

  def encrypt_sym_key(user, sym_key_to_encrypt)
    return if user&.public_key.blank? || sym_key_to_encrypt.blank?

    new_public_key = OpenSSL::PKey::RSA.new(user.public_key)
    encrypted_sym_key = new_public_key.public_encrypt(sym_key_to_encrypt)
    Base64.encode64(encrypted_sym_key)
  end

  def decrypt_sym_key(user_decrypted_private_key, encrypted_sym_key_base64)
    return if user_decrypted_private_key.nil? || encrypted_sym_key_base64.nil?

    encrypted_sym_key = Base64.decode64(encrypted_sym_key_base64)
    new_private_key = OpenSSL::PKey::RSA.new(user_decrypted_private_key)
    begin
      new_private_key.private_decrypt(encrypted_sym_key)
    rescue OpenSSL::PKey::RSAError
      nil
    end
  end

  def generate_sym_key(user)
    return if user&.public_key.blank?

    salt = SecureRandom.random_bytes(1024)
    ActiveSupport::KeyGenerator.new(user.public_key).generate_key(salt)
  end

  # ******************************************#

  # Group

  # Decrypt

  def decrypted_group_key(group)
    current_user.admin? ? decrypted_group_key_for_admin(group) : decrypted_group_key_for_user(group)
  end

  def decrypted_group_key_for_admin(group)
    decrypt_sym_key(decrypted_current_user_private_key, group.group_admin_keys.find_by(user: current_user)&.key)
  end

  def decrypted_group_key_for_user(group)
    decrypt_sym_key(decrypted_current_user_private_key, group.group_users.find_by(user: current_user)&.group_key)
  end

  # Update

  # Fill admin keys for all admins from current team
  def assign_group_admin_keys(group, group_key)
    current_user.team.users.where(role_id: %w[admin support]).find_each do |user|
      group.group_admin_keys.where(user: user).first_or_create(key: encrypt_sym_key(user, group_key))
    end
  end

  # Assign group key for users or leads
  def assign_group_user_key(user, group_user, group_key)
    group_user.group_key = encrypt_sym_key(user, group_key)
  end

  # Assign group vault key
  def assign_group_vault_key(group_vault, decrypted_group_key, decrypted_vault_key)
    group_vault.vault_key = encrypt_content(decrypted_group_key, decrypted_vault_key)
  end

  def update_group_vaults_keys(group, vault, group_vault)
    decrypted_vault_key, decrypted_group_key = if current_user.admin?
                                                 [decrypted_vault_key_for_admin(vault), decrypted_group_key_for_admin(group)]
                                               else
                                                 [decrypted_vault_key_for_user(vault), decrypted_group_key_for_user(group)]
                                               end
    return if decrypted_vault_key.nil? || decrypted_group_key.nil?

    assign_group_vault_key(group_vault, decrypted_group_key, decrypted_vault_key)
  end

  # Vault

  # Decrypt

  def decrypted_vault_key(vault)
    current_user.admin? ? decrypted_vault_key_for_admin(vault) : decrypted_vault_key_for_user(vault)
  end

  def decrypted_vault_key_for_admin(vault)
    user_decrypted_private_key = decrypted_current_user_private_key
    encrypted_vault_key = if vault.is_shared
                            vault.vault_admin_keys.find_by(user: current_user)&.key
                          else
                            UserVault.find_by(user: current_user, vault: vault)&.vault_key
                          end
    decrypt_sym_key(user_decrypted_private_key, encrypted_vault_key)
  end

  def decrypted_vault_key_for_user(vault)
    user_private_key = decrypted_current_user_private_key
    user_vault = UserVault.find_by(user: current_user, vault: vault)
    if user_vault.nil?
      group_user = nil
      vault.groups.each do |group|
        group_user = GroupUser.find_by(group: group, user: current_user)
        break unless group_user.nil?
      end
      return if group_user.nil?

      decrypted_group_key = decrypt_sym_key(user_private_key, group_user.group_key)
      group_vault = GroupVault.find_by(group: group_user.group, vault: vault)
      decrypted_vault_key = decrypt_content(decrypted_group_key, group_vault.vault_key)
    else
      decrypted_vault_key = decrypt_sym_key(user_private_key, user_vault.vault_key)
    end
    decrypted_vault_key
  end

  # Update

  def update_user_vaults_keys(user, vault, user_vault)
    decrypted_vault_key = if current_user.admin?
                            decrypted_vault_key_for_admin(vault)
                          else
                            decrypted_vault_key_for_user(vault)
                          end
    return if decrypted_vault_key.nil?

    assign_user_vault_key(user, user_vault, decrypted_vault_key)
  end

  # Assign vault key for users or leads
  def assign_user_vault_key(user, user_vault, vault_key)
    user_vault.vault_key = encrypt_sym_key(user, vault_key)
  end

  def update_vault_key_for_admin_users(user, vault, vault_key)
    user.team.users.where(role_id: %w[admin support]).find_each do |admin|
      vault.vault_admin_keys.where(user: admin).first_or_create(key: encrypt_sym_key(admin, vault_key))
    end
  end

  # Vault Item

  # Decrypt

  def decrypted_content(item)
    vault = item.vault
    decrypted_vault_key = if current_user.admin?
                            decrypted_vault_key_for_admin(vault)
                          else
                            decrypted_vault_key_for_user(vault)
                          end
    return if decrypted_vault_key.nil? || item.content.blank?

    JSON.parse(decrypt_content(decrypted_vault_key, item.content))
  end

  # Update

  def update_encrypted_content(content, vault)
    decrypted_vault_key = if current_user.admin?
                            decrypted_vault_key_for_admin(vault)
                          else
                            decrypted_vault_key_for_user(vault)
                          end
    return if decrypted_vault_key.nil?

    encrypt_content(decrypted_vault_key, content.to_json)
  end

  # Change user role

  def update_role_to_admin(user)
    current_user.team.vaults.find_each do |vault|
      vault.vault_admin_keys.where(user: user).first_or_create(key: encrypt_sym_key(user, decrypted_vault_key_for_admin(vault)))
    end
    current_user.team.groups.find_each do |group|
      group.group_admin_keys.where(user: user).first_or_create(key: encrypt_sym_key(user, decrypted_group_key_for_admin(group)))
    end
  end

  # encrypted decrypted file

  def update_encrypted_file(model, vault)
    decrypted_vault_key = if current_user.admin?
                            decrypted_vault_key_for_admin(vault)
                          else
                            decrypted_vault_key_for_user(vault)
                          end

    return if decrypted_vault_key.nil?

    encrypt_file(decrypted_vault_key, model.file)
  end

  def decrypted_file(item, vault)
    decrypted_vault_key = if current_user.admin?
                            decrypted_vault_key_for_admin(vault)
                          else
                            decrypted_vault_key_for_user(vault)
                          end
    return if decrypted_vault_key.nil? || item.content.blank?


    decrypt_file(decrypted_vault_key, item.content, item.file_name)
  end

  def encrypt_file(sym_key, document)
    return if sym_key.nil? || document.blank?

    encrypted_content = ''
    encrypted_file_name = ''
    crypt = ActiveSupport::MessageEncryptor.new(sym_key, cipher: 'aes-256-cbc')
    File.open(document.path, 'r+') do |file|
      encrypted_content = crypt.encrypt_and_sign(file.read)
      encrypted_file_name = crypt.encrypt_and_sign(document.original_filename)
    end
    { file_name: Base64.encode64(encrypted_file_name), content: Base64.encode64(encrypted_content) }
  end

  def decrypt_file(decrypted_vault_key, content, file_name)
    encrypted_content_base64 = content
    encrypted_file_name_base64 = file_name
    return if decrypted_vault_key.blank? || encrypted_content_base64.blank?

    encrypted_content = Base64.decode64(encrypted_content_base64)
    encrypted_file_name = Base64.decode64(encrypted_file_name_base64)
    crypt = ActiveSupport::MessageEncryptor.new(decrypted_vault_key, cipher: 'aes-256-cbc')
    { file_name: crypt.decrypt_and_verify(encrypted_file_name), content: crypt.decrypt_and_verify(encrypted_content) }
  end
end

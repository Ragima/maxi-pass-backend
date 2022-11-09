# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    file { File.new("#{Rails.root}/spec/support/fixtures/test.txt") }
    content { FFaker::Lorem.unique.word }
    encrypted { true }
    file_name { FFaker::Lorem.unique.word }
    association :vault_item, factory: :server_item
  end

  factory :group_admin_key do
  end

  factory :vault_admin_key do
  end

  factory :team do
    otp_required_for_login { false }
    name { FFaker::Name.unique.name }
    support_personal_vaults { true }
  end

  factory :group do
    name { FFaker::Name.unique.name }
    team
  end

  factory :user do
    team
    email { FFaker::Internet.email }
    password { 'BSFExfVDuVKdkUorAlNtBm3/' }
    temp_phrase { FFaker::Internet.password }
    first_name { FFaker::Name.first_name }
    last_name { FFaker::Name.last_name }
    name { FFaker::Name.name }
    confirmed_at { Time.zone.now }
    otp_required_for_login { true }
    otp_secret { User.generate_otp_secret }
    role_id { 'user' }
    reset_pass { false }
    reset_password_token { nil }
    reset_password_sent_at { nil }

    factory :unauthorized_user do
      team { nil }
      temp { 'bla' }
      confirmed_at { nil }
    end
    factory :admin do
      role_id { 'admin' }
    end
    factory :support do
      role_id { 'support' }
    end
    factory :invited_user do
      invitation_token { FFaker::Lorem.unique.word }
      invitation_created_at { DateTime.now }
      invitation_sent_at { DateTime.now }
    end
  end

  factory :subscription_action do
    entity_type { FFaker::Lorem.unique.word }
    action_type { FFaker::Lorem.unique.word }
  end

  factory :subscription do
    association :user, factory: :admin
    subscription_action
  end

  factory :vault do
    title { FFaker::Lorem.word }
    description { FFaker::Lorem.word }
    team
    factory :shared_vault do
      is_shared { true }
    end
    factory :private_vault do
      is_shared { false }
    end
  end

  factory :login_item do
    type { 'LoginItem' }
    title { FFaker::Lorem.word }
    tags { "#{FFaker::Lorem.word} #{FFaker::Lorem.word}" }
    content { nil }
    only_for_admins { false }
    vault
  end

  factory :credit_card_item do
    type { 'CreditCardItem' }
    title { FFaker::Lorem.word }
    tags { "#{FFaker::Lorem.word} #{FFaker::Lorem.word}" }
    content { nil }
    only_for_admins { false }
    vault
  end

  factory :server_item do
    type { 'ServerItem' }
    title { FFaker::Lorem.word }
    tags { "#{FFaker::Lorem.word} #{FFaker::Lorem.word}" }
    content { nil }
    only_for_admins { false }
    vault
  end

  factory :user_vault do
    user
    vault
  end

  factory :activity do
    owner_type { 'User' }
    trackable_type { 'User' }
    action_type { 'User' }
    action_act { 'Login' }
  end
end

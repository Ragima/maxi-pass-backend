# frozen_string_literal: true

module User::Operation
  class UpdateSettings < Trailblazer::Operation
    step :model!
    step Contract::Build(constant: User::Contract::UpdateSettings)
    step Contract::Validate(key: :user)
    step Contract::Persist(method: :sync)
    step :check_password_updated!
    step :save_model!
    step :serialized_model!

    def model!(options, current_user:, **)
      options['password_changed'] = false
      options[:model] = current_user
    end

    def check_password_updated!(options, model:, params:, **)
      options[:password_params] = password_params = password_resource_params(params)
      return true unless password_params[:password]

      current_password = password_params.delete(:current_password)

      result = if Devise::Encryptor.compare(model.class, model.encrypted_password, current_password)
                 model.assign_attributes(password_params)
                 model.password_changed_at = Time.now.utc
                 true
               else
                 model.valid?
                 options['contract.default'].errors.add(:current_password, current_password.blank? ? :blank : :invalid)
                 false
               end

      model.valid?
      model.errors.messages.each do |key, value|
        options['contract.default'].errors.add(key, value.first)
      end
      result
    end

    def save_model!(options, model:, current_user:, password_params:, **)
      if password_params[:password]
        encoder = Encoder.new(current_user)
        model.assign_attributes(private_key:
                                    encoder.encrypt_user_private_key(current_user,
                                                                     password_params[:password],
                                                                     OpenSSL::PKey::RSA.new(encoder.decrypted_current_user_private_key)))
        options['password_changed'] = true if model.encrypted_password_changed?
      end
      model.save
    end

    def serialized_model!(options, model:, **)
      options[:serialized_model] = User::Representer::Show.new(model).to_hash(user_options: { password_changed: options['password_changed'] })
    end

    private

    def password_resource_params(params)
      params.require(:user).permit(:password, :password_confirmation, :current_password)
    end
  end
end

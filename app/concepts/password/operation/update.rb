# frozen_string_literal: true

module Password::Operation
  class Update < Trailblazer::Operation
    step :model!
    step Contract::Build(constant: Password::Contract::Update)
    step Contract::Validate()
    step Contract::Persist(method: :sync)
    step :save_model!

    def model!(options, current_user:, **)
      options[:model] = current_user
    end

    def save_model!(options, params:, model:, **)
      # TODO: refactor
      model.temp_phrase = password = params[:password]
      encoder = Encoder.new(model)
      rsa_key = encoder.generate_user_private_key
      public_key = rsa_key.public_key.to_pem
      private_key = encoder.encrypt_user_private_key(model, password, rsa_key)
      model.assign_attributes(public_key: public_key,
                              private_key: private_key,
                              reset_pass: true,
                              change_pass: false,
                              password_changed_at: Time.now.utc, password: password)
      model.valid?
      model.errors.messages.each do |key, value|
        options['contract.default'].errors.add(key, value.first)
      end
      model.save
    end
  end
end

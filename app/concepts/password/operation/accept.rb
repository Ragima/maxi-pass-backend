# frozen_string_literal: true

module Password::Operation
  class Accept < Trailblazer::Operation
    step Model(User, :find_by_reset_password_token, :reset_password_token)
    step Policy::Guard(:reset_password_period_valid?)
    step :update_model!
    success :generate_tokens!

    def reset_password_period_valid?(_options, model:, **)
      model.reset_password_sent_at && model.reset_password_sent_at.utc >= Devise.reset_password_within.ago.utc
    end

    def update_model!(_options, model:, **)
      model.update_attributes(change_pass: true, public_key: nil, private_key: nil)
    end

    def generate_tokens!(options, model:, **)
      options[:client_id], options[:token] = model.create_token
      model.save
    end
  end
end

# frozen_string_literal: true

module User::Representer
  class Show < Representable::Decorator
    include Representable::Hash

    nested :data do
      property :id
      property :email
      property :first_name
      property :last_name
      property :name
      property :team_name
      property :role_id
      property :reset_pass
      property :blocked
      property :extension_access
      property :lead, exec_context: :decorator
      property :password_expired, exec_context: :decorator
      property :otp_required, exec_context: :decorator
      property :locale
      property :password_changed, getter: ->(user_options:, **) { user_options[:password_changed] }

      def lead
        GroupUser.exists?(user: represented, role: 'lead')
      end

      def password_expired
        represented.password_changed_at.blank? ? false : represented.password_changed_at + 3.months < Time.now.utc
      end

      def otp_required
        represented.team.otp_required_for_login
      end
    end
  end
end

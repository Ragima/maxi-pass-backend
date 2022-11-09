class AddOtpRequiredForLoginToTeam < ActiveRecord::Migration[5.2]
  def change
    add_column :teams, :otp_required_for_login, :boolean, default: false
  end
end

class InvitationSerializer
  include FastJsonapi::ObjectSerializer
  attributes :email, :role_id, :first_name, :last_name, :name, :invited_by_name, :accept_to
end

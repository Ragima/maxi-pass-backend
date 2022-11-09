class UserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :email, :role_id, :first_name, :last_name, :name

  has_many :group
end

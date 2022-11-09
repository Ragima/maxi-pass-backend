class GroupSerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :parent_group_id

  has_many :users
  has_many :vaults
end
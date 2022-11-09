class VaultSerializer
  include FastJsonapi::ObjectSerializer
  attributes :title, :description, :created_at, :updated_at
end

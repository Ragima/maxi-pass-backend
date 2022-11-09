# frozen_string_literal: true

module ServerItem::Operation
  class Show < VaultItem::Operation::Show
    include ServerItem::Concern::EntityConcern
  end
  class Create < VaultItem::Operation::Create
    include ServerItem::Concern::EntityConcern
  end
  class Update < VaultItem::Operation::Update
    include ServerItem::Concern::EntityConcern
  end
  class Destroy < VaultItem::Operation::Destroy
    include ServerItem::Concern::EntityConcern
  end
  class Copy < VaultItem::Operation::Copy
    include ServerItem::Concern::EntityConcern
  end
  class Move < VaultItem::Operation::Move
    include ServerItem::Concern::EntityConcern
  end
end
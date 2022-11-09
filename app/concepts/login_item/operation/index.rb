# frozen_string_literal: true

module LoginItem::Operation
  class Show < VaultItem::Operation::Show
    include LoginItem::Concern::EntityConcern
  end
  class Create < VaultItem::Operation::Create
    include LoginItem::Concern::EntityConcern
  end
  class Update < VaultItem::Operation::Update
    include LoginItem::Concern::EntityConcern
  end
  class Destroy < VaultItem::Operation::Destroy
    include LoginItem::Concern::EntityConcern
  end
  class Copy < VaultItem::Operation::Copy
    include LoginItem::Concern::EntityConcern
  end
  class Move < VaultItem::Operation::Move
    include LoginItem::Concern::EntityConcern
  end
end
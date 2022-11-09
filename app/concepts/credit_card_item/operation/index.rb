# frozen_string_literal: true

module CreditCardItem::Operation
  class Show < VaultItem::Operation::Show
    include CreditCardItem::Concern::EntityConcern
  end
  class Create < VaultItem::Operation::Create
    include CreditCardItem::Concern::EntityConcern
  end
  class Update < VaultItem::Operation::Update
    include CreditCardItem::Concern::EntityConcern
  end
  class Destroy < VaultItem::Operation::Destroy
    include CreditCardItem::Concern::EntityConcern
  end
  class Copy < VaultItem::Operation::Copy
    include CreditCardItem::Concern::EntityConcern
  end
  class Move < VaultItem::Operation::Move
    include CreditCardItem::Concern::EntityConcern
  end
end
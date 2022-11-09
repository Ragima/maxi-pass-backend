# frozen_string_literal: true

module Api::V1
  class PagesController < VaultItemsController
    include KeysConcern

    before_action :decrypt_temp_phrase

  def home
     endpoint operation: Page::Operation::Home,
              options: { current_user: current_user }
  end
  end
end

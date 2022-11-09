# frozen_string_literal: true

module VaultItem::Callable
  class ExtractParams
    extend Uber::Callable

    def self.call(options, params:,  **)
      params_entity = params[options[:entity_sym]]
      params_entity = params_entity&.to_unsafe_h unless params_entity.is_a?(Hash)
      options['contract.default.params'] = params_entity&.slice(:title, :tags, :only_for_admins)
      options['contract.default.closed_params'] = params_entity&.except(:title, :tags, :only_for_admins)
    end

  end
end
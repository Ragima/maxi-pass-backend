# frozen_string_literal: true

class VaultInformationPdf < Prawn::Document
  def initialize(vault, vault_items)
    super(top_margin: 70)
    @vault = vault
    @vault_items = vault_items
    font(Rails.root.join("public/fonts/OpenSans-Regular.ttf")) do
      table vault_with_items, header: true
    end
  end

  def vault_with_items
    table = if @vault_items.present?
              @vault_items.where(only_for_admins: [false, nil]).map { |item| render_vault(@vault) + render_vault_item(item) }
            else
              [render_vault(@vault)]
            end
    text vault_for_report
    table_header + table
  end

  private

  def vault_for_report
    "Vault: #{@vault&.title}"
  end

  def table_header
    [%w[Vaults Items]]
  end

  def render_vault(vault)
    [(vault&.title).to_s]
  end

  def render_vault_item(item)
    ["#{item&.type}: #{item&.title}"]
  end
end

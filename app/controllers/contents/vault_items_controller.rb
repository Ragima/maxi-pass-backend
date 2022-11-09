# frozen_string_literal: true
module Contents
  class VaultItemsController < ApplicationController
    include KeysConcern

    before_action :decrypt_temp_phrase
    before_action :master_key, only: [:index]
    before_action :find_login_item, only: [:show]

    def index
      @vault_items = @current_user.all_login_items
      @vault_items.each do |item|
        item.decrypted_content = encoder.decrypted_content(item)
      end
    end

    def show
      @vault_item.decrypted_content = encoder.decrypted_content(@vault_item)
      render :show
    end

    private

    def encoder
      @encoder ||= Encoder.new(@current_user)
    end

    def find_login_item
      @vault_item = @current_user.all_login_items.detect { |item| item.id.to_s == params[:id] }
      head(:not_found) if @vault_item.nil?
    end
  end
end

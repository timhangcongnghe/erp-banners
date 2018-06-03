class AddNoteToErpBannersBanners < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_banners_banners, :note, :text
  end
end

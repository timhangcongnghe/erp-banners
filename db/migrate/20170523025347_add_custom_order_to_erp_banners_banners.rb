class AddCustomOrderToErpBannersBanners < ActiveRecord::Migration[5.0]
  def change
    add_column :erp_banners_banners, :custom_order, :integer
  end
end

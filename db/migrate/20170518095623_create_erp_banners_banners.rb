class CreateErpBannersBanners < ActiveRecord::Migration[5.0]
  def change
    create_table :erp_banners_banners do |t|
      t.string :image_url
      t.string :name
      t.string :link_url
      t.boolean :archived, default: false
      t.references :category, index: true, references: :erp_banners_categories
      t.references :creator, index: true, references: :erp_users

      t.timestamps
    end
  end
end

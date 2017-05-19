class CreateErpBannersCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :erp_banners_categories do |t|
      t.string :name
      t.integer :width
      t.integer :height
      t.string :image_scale
      t.boolean :archived, default: false
      t.references :creator, index: true, references: :erp_users

      t.timestamps
    end
  end
end

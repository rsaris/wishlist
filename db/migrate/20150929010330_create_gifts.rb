class CreateGifts < ActiveRecord::Migration
  def change
    create_table :gifts do |t|
      t.integer :user_id
      t.integer :buyer_user_id
      t.string :name
      t.string :description
      t.timestamps
    end
  end
end

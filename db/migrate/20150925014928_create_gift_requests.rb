class CreateGiftRequests < ActiveRecord::Migration
  def change
    create_table :gift_requests do |t|
      t.integer :user_id
      t.string :name
      t.string :description
      t.timestamps
    end
  end
end

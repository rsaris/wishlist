class AddPurchasedByFlagToGiftRequest < ActiveRecord::Migration
  def change
    add_column :gift_requests, :purchased_by_user_id, :integer
  end
end

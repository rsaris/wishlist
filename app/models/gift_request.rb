class GiftRequest < ActiveRecord::Base
  belongs_to :user

  validates :user, presence: true
  validates :name, presence: true

  def purchased?
    !self.purchased_by_user_id.nil?
  end

  def purchasing_user
    if self.purchased_by_user_id.nil?
      nil
    else
      User.find( self.purchased_by_user_id )
    end
  end
end

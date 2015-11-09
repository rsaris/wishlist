class Gift < ActiveRecord::Base
  belongs_to :user
  belongs_to :buyer, foreign_key: :buyer_user_id, inverse_of: :gifts_purchased, class_name: 'User'

  validates :user, presence: true
  validates :buyer, presence: true
  validates :name, presence: true
end

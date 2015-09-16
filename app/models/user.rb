class User < ActiveRecord::Base
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: ApplicationHelper.email_regex }
  validates :full_name, presence: true, format: { with: /.+\s.+/, message: 'requires first and last name.' }

  has_many :remember_tokens, dependent: :destroy

  has_many :regular_friendships, foreign_key: :user_id, class_name: 'Friendship', dependent: :destroy
  has_many :inverse_friendships, foreign_key: :friend_id, class_name: 'Friendship', dependent: :destroy

  has_secure_password

  scope :by_search, -> (search) { search.nil? ? all : where( 'full_name like ?', "%#{search}%") }

  before_save do
    self.email = email.downcase
  end

  def friends
    self.regular_friendships.to_a.concat( self.inverse_friendships.to_a ).select{ |friendship| friendship.accepted }.map{ |friendship| friendship.user_id == self.id ? friendship.friend : friendship.user }
  end
end

class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, foreign_key: :friend_id, class_name: 'User'

  validates :friend_id, presence: true
  validates :user_id, presence: true
  validate :different_users
  validate :unique_friendship

  before_create :seed_accepted

  scope :with_friend, ->{ includes( :friend ) }
  scope :with_user, ->{ includes( :user ) }

  private
  def different_users
    if self.user_id == self.friend_id
      self.errors.add( :friend_id, 'must be different from user.' )
    end
  end

  def unique_friendship
    if Friendship.where( '(user_id = ? and friend_id = ?) or (friend_id = ? and user_id =?)', self.user_id, self.friend_id, self.user_id, self.friend_id ).exists?
      self.errors.add( :user_id, 'already has a friendship created.' )
    end
  end

  def seed_accepted
    self.accepted = false
    return true
  end
end

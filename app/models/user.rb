class User < ActiveRecord::Base
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: ApplicationHelper.email_regex }
  validates :full_name, presence: true, format: { with: /.+\s.+/, message: 'requires first and last name.' }

  has_many :remember_tokens, dependent: :destroy

  has_many :regular_friendships, foreign_key: :user_id, class_name: 'Friendship', dependent: :destroy
  has_many :inverse_friendships, foreign_key: :friend_id, class_name: 'Friendship', dependent: :destroy

  has_secure_password

  before_save do
    self.email = email.downcase
  end

  def friends
    User.find( friend_ids )
  end

  def has_friend?( user )
    Friendship.where( '((user_id = ? and friend_id = ?) or (friend_id = ? and user_id = ?)) and accepted = ?', user.id, self.id, user.id, self.id, true ).exists?
  end

  def User.search( search_term )
    if search_term.nil?
      return []
    elsif search_term.match( ApplicationHelper.email_regex )
      User.where( 'email like ?', "%#{search_term}%" )
    else
      User.where( 'full_name like ?', "%#{search_term}%")
    end
  end

  private
  def friend_ids
    regular_friend_ids = self.regular_friendships.select{
      |friendship| friendship.accepted?
    }.map{
      |friendship| friendship.friend_id
    }

    inverse_friend_ids = self.inverse_friendships.select{
      |friendship| friendship.accepted?
    }.map{
      |friendship| friendship.user_id
    }

    regular_friend_ids.concat( inverse_friend_ids )
  end
end

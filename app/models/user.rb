class User < ActiveRecord::Base
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: ApplicationHelper.email_regex }
  validates :full_name, presence: true, format: { with: /.+\s.+/, message: 'requires first and last name.' }

  has_many :remember_tokens, dependent: :destroy

  has_many :regular_friendships, foreign_key: :user_id, class_name: 'Friendship', dependent: :destroy
  has_many :inverse_friendships, foreign_key: :friend_id, class_name: 'Friendship', dependent: :destroy

  has_many :gift_requests, dependent: :destroy
  has_many :gifts, dependent: :destroy
  has_many :gifts_purchased, foreign_key: :buyer_user_id, class_name: 'Gift', inverse_of: :buyer, dependent: :destroy

  accepts_nested_attributes_for :gift_requests, allow_destroy: true

  has_secure_password

  scope :by_search, ->(search_term) {
    if search_term.nil?
      none
    else
      where( 'full_name ilike any(array[?]) or email ilike ?', search_term.split( " " ).map{ |term| "%#{term}%" }, "%#{search_term}%" )
    end
  }

  before_save do
    self.email = email.downcase
  end

  def friends
    User.find( friend_ids )
  end

  def has_friend?( user )
    self.has_friend_with_id?( user.id )
  end

  def has_friend_with_id?( user_id )
    Friendship.where( '((user_id = ? and friend_id = ?) or (friend_id = ? and user_id = ?)) and accepted = ?', user_id, self.id, user_id, self.id, true ).exists?
  end

  def friend_requests( options = {} )
    scope = Friendship

    if options[:include_friends]
      scope = scope.with_friend
    end

    if options[:include_users]
      scope = scope.with_user
    end

    scope.where( 'friend_id = ? and accepted = ?', self.id, false )
  end

  def pending_request( friend )
    Friendship.find_by( 'user_id = ? and friend_id = ? and accepted = ?', self.id, friend.id, false )
  end

  def header_link_text
    num_friend_requests = self.friend_requests.count
    'My Account' + (num_friend_requests > 0 ? " (#{num_friend_requests})" : '')
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

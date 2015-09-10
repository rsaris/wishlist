class RememberToken < ActiveRecord::Base
  belongs_to :user

  validates :user_id, presence: true
  validates :remember_token, presence: true

  before_create do
    self.last_used = Time.now
  end

  def RememberToken.find_user( user_id, remember_token )
    tokens = RememberToken.includes( :user ).where( 'user_id = ? and remember_token = ?', user_id, RememberToken.create_digest( remember_token ) )
    if tokens.length == 0
      return nil
    end

    token = tokens.first
    if token.is_valid?
      token.update_last_used!
      return token.user
    else
      # if the token is invalid, delete it
      token.destroy
      return nil
    end
  end

  def RememberToken.find_token( user_id, remember_token )
    tokens = RememberToken.where( 'user_id = ? and remember_token = ?', user_id, RememberToken.create_digest( remember_token ) )
    if tokens.count == 0
      return nil
    end

    token = tokens.first
    if token.is_valid?
      token.update_last_used!
      return token
    else
      # if the token is invalid, delete it
      token.destroy
      return nil
    end
  end

  def RememberToken.build_remember_token( user )
    token_string = SecureRandom.urlsafe_base64
    token = RememberToken.create( { :user_id => user.id, :remember_token => RememberToken.create_digest( token_string ) } )
    return token_string
  end

  def is_valid?
    return Time.now - self.last_used < ttl
  end

  def update_last_used!
    self.update_attribute( :last_used, Time.now )
  end

  ############### PRIVATE ########################
  private

  def ttl
    num_days = 14
    return num_days * 24 * 60 * 60
  end

  def RememberToken.create_digest( token )
    Digest::SHA1.hexdigest( token.to_s )
  end
end
class User < ActiveRecord::Base
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: ApplicationHelper.email_regex }
  validates :full_name, presence: true, format: { with: /.+\s.+/, message: 'requires first and last name.' }

  has_secure_password

  before_save do
    self.email = email.downcase
  end
end

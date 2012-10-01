# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  email                  :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  password_digest        :string(255)
#  remember_token         :string(255)
#  admin                  :boolean          default(FALSE)
#  password_reset_token   :string(255)
#  password_reset_sent_at :datetime
#  email_confirm_token    :string(255)
#  user_state             :boolean
#

class User < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation

  # as long as there is a 'password_digest' column in the db, adding this one method
  # to our model gives us a secure way to create and authenticate new users
  # see: https://github.com/rails/rails/blob/master/activemodel/lib/active_model/secure_password.rb
  # password and password_confirmation attributes are added magically
  # authenticate method is also added magically
  has_secure_password

  has_many :microposts, dependent: :destroy

  has_many :relationships, foreign_key: "follower_id", 
                           dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed

  has_many :reverse_relationships, foreign_key: "followed_id", 
                                   class_name: "Relationship",
                                   dependent: :destroy
  has_many :followers, through: :reverse_relationships, source: :follower

  # callback method ensuring email uniqueness by downcasing the email attr. before save
  before_save { self.email.downcase! }
  before_save { create_token(:remember_token) }

  # default user_state is false, users need to verify email
  after_create { set_user_state_false }

  validates :name, presence: true, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, 
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  validates :password, length: { minimum: 6 }

  validates :password_confirmation, presence: true

  def feed
    Micropost.from_users_followed_by(self)
  end

  def following?(other_user)
    # equivalent to self.relationships...
    self.relationships.find_by_followed_id(other_user.id)
  end

  def follow!(other_user)
    # equivalent to self.relationships...
    self.relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    self.relationships.find_by_followed_id(other_user.id).destroy
  end

  def send_password_reset
    create_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save! validate: false
    UserMailer.password_reset(self).deliver
  end

  def send_email_confirm
    create_token(:email_confirm_token)
    save! validate: false
    UserMailer.email_confirm(self).deliver
  end

  def set_user_state_false
    self.toggle!(:user_state)
    self.toggle!(:user_state)
  end

  private

    def create_token(column)
      self[column] = SecureRandom.urlsafe_base64
    end
end

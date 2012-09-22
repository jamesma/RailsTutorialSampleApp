# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string(255)
#

class User < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation

  # as long as there is a 'password_digest' column in the db, adding this one method
  # to our model gives us a secure way to create and authenticate new users
  # see: https://github.com/rails/rails/blob/master/activemodel/lib/active_model/secure_password.rb
  # password and password_confirmation attributes are added magically
  # authenticate method is also added magically
  has_secure_password

  # callback method ensuring email uniqueness by downcasing the email attr. before save
  before_save { self.email.downcase! }

  validates :name, presence: true, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, 
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  validates :password, presence: true, length: { minimum: 6 }

  validates :password_confirmation, presence: true
end
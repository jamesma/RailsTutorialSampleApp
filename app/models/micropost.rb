class Micropost < ActiveRecord::Base
  # only content attribute is editable through the web
  attr_accessible :content

  belongs_to :user

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }

  # order from oldest to newest
  default_scope order: 'microposts.created_at DESC'
end

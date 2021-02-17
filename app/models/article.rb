class Article < ApplicationRecord
  validates :user_id, presence:true
  validates :title, :content, presence:true

  belongs_to :user
end

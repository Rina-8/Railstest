class Article < ApplicationRecord
  validates :user_id, presence:true
  validates :title, :content, presence:true
end

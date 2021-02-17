class Article < ApplicationRecord
  validates :user_id, presence:true
end

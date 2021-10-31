class Message < ApplicationRecord
  belongs_to :user
  belongs_to :reciver, class_name: 'User', foreign_key: :reciver

  has_many_attached :images

  scope from: ->(user){ where(user: user) }
  scope to: ->(user){ where(reciver: user) }
end

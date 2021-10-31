class Message < ApplicationRecord
  belongs_to :user
  belongs_to :reciver, class_name: 'User', foreign_key: :reciver

  has_many_attached :images

  scope sended_by: ->(user){ where(user: user) }
  scope recived_by: ->(user){ where(reciver: user) }
end

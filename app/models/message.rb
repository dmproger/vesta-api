class Message < ApplicationRecord
  belongs_to :user
  belongs_to :reciver, class_name: 'User', foreign_key: :reciver, optional: true

  enum kind: { to_support: 1 }

  has_many_attached :images

  scope :form_user, ->(user){ where(user: user) }
  scope :to_user, ->(user){ where(reciver: user) }
end

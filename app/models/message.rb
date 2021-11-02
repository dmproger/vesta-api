class Message < ApplicationRecord
  KINDS = {
    to_support: 'Cлужба поддержки'
  }

  belongs_to :user
  belongs_to :reciver, class_name: 'User', foreign_key: :reciver, optional: true

  enum kind: { to_support: 1 }

  has_many_attached :images

  scope :form_user, ->(user){ where(user: user) }
  scope :to_user, ->(user){ where(reciver: user) }


  def self.ui_kinds
    Message.kinds.map { |k, v| [v, KINDS[k.to_sym]] }.to_h
  end
end

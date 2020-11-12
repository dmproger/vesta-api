class JointTenant < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search, against: [:name],
                  using: {tsearch: {prefix: true, any_word: true}}

  belongs_to :tenant

  validates :name, presence: true
  validates :price, presence: true
end

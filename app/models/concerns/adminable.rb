module Adminable
  extend ActiveSupport::Concern

  included do
    def count
      super&.values.sum
    end
  end

  class_methods do
    def count
      super.values.sum
    end
  end
end

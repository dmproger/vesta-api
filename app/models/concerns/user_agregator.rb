module UserAgregator
  extend ActiveSupport::Concern

  included do |base|
    base.table_name = 'users'

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

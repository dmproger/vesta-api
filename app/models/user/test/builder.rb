class User
  module Test
    module Builder
      PHONES = ENV['PHONES']&.split(' ') || \
        %w[+447768333333]

      class << self
        def build
          for @phone, @i in PHONES.each_with_index
            @user = User.find_by(phone: @phone) || User.joins(:saved_transactions).first
            for @account, @transactions in @user.saved_transactions.group(:id, :account_id).each_with_object({}) { |r, o| (o[r.account] ||= [])<< r }
              @i += 1
              @model = create_model
              config_model
            end
          end
        end

        def create_model
          @model_name = model_name
          superclass = Class.new(ActiveRecord::Base)
          User::Test.const_set(@model_name, superclass)

          "User::Test::#{ @model_name }".constantize
        end

        def config_model
          @tids = @transactions.pluck(:id)
          @model.class_eval <<-STR
            self.table_name = 'saved_transactions'
            default_scope { where(id: #{ @tids }) }
          STR
        end

        def model_name
          client = @account.holder_name.gsub(/\s*/, '').classify
          "#{ client }_Bank#{ @i }"
        end
      end
    end
  end
end

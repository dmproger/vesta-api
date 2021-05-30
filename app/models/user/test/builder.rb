class User
  module Test
    module Builder
      PHONES = ENV['PHONES']&.split(' ') || \
        %w[
          +447758639852
          +447785136253
          +447785122365
        ]

      class << self
        attr_reader :models

        def build
          @models = []

          for @phone in PHONES
            if @user = User.find_by(phone: @phone)
              create_account unless @user.accounts.any?

              @user_module = "U#{ @phone.gsub(/\D/, '') }"
              @namespace = User::Test.const_set(@user_module, Module.new)

              @i = 0
              for @account, @transactions in @user.reload.saved_transactions.group(:id, :account_id).each_with_object({}) { |r, o| (o[r.account] ||= [])<< r }
                @i += 1
                @model = create_model
                config_model
                @models << @model
              end
            end
          end
        end

        def create_account
          account = Account.create!(
            user: @user,
            holder_name: 'Testname Testname'
          )

          @user.saved_transactions.create!(
            account: account,
            amount: 0,
            category_type: 'TEST',
            description: 'TEST',
            transaction_date: Time.current
          )
        end

        def create_model
          superclass = Class.new(ActiveRecord::Base)
          @model_name = model_name

          @namespace.const_set(@model_name, superclass)
        end

        def config_model
          @model.class_eval do
            self.table_name = 'saved_transactions'

            before_save do |record|
              defaults = self.class.first.attributes.delete_if { |k| k == 'id' }

              current = record.attributes.keep_if { |_, v| !v.nil? }
              current.merge!(
                is_processed: false,
                is_associated: false
              )

              record.assign_attributes(defaults.merge(current))
            end
          end

          @model.class_eval <<-STR
            default_scope { where(account_id: '#{ @account.id }') }
          STR
        end

        def model_name
          client = @account.holder_name.gsub(/\s*/, '').classify
          "#{ @user_module }Bank#{ @i }"
        end
      end
    end
  end
end

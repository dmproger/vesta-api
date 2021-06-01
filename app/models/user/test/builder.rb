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
              for @account in @user.reload.accounts
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

            self.has_one :associated_transaction, dependent: :destroy,
              class_name: 'AssociatedTransaction',
              foreign_key: 'saved_transaction_id'

            before_save do |record|
              ignores = %w[user_id account_id]
              defaults = self.class.new.attributes.delete_if { |attr| ignores.include?(attr) }
              current = record.attributes

              record.associated_transaction&.destroy

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

class User
  module Test
    module Builder
      PHONES = ENV['PHONES']&.split(' ') || \
        %w[
          +447758639852
          +447785136253
          +447785122365
          +4477555555
        ]

      PHONES << '+4489613464' if Rails.env.development?

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

                create_default_transaction unless @user.saved_transactions.any?
              end
            end
          end
        end

        def create_account
          Account.create!(
            user: @user,
            holder_name: 'Testname Testname',
            bank_id: Time.now.to_i.to_s,
            account_number: Time.now.to_i.to_s,
            account_id: "#{ @user.id.gsub(/[-]/, '') }#{ Time.now.to_i.to_s }"
          )
        end

        def create_default_transaction
          @user.saved_transactions.create!(
            account: @account,
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
          @model.table_name = 'saved_transactions'

          @model.has_one :associated_transaction, dependent: :destroy,
            class_name: 'AssociatedTransaction',
            foreign_key: 'saved_transaction_id'

          @model.before_save :user_account_association!
          @model.before_save :destroy_associated_transaction!

          @model.class_eval <<-STR
            default_scope { where(account_id: '#{ @account.id }', user_id: '#{ @user.id }') }
          STR
          
          @model.class_eval <<-STR
            def user_account_association!
              self.user_id = '#{ @user.id }'
              self.account_id = '#{ @account.id }'
            end
          STR

          @model.class_eval do
            def destroy_associated_transaction!
              associated_transaction&.destroy
            end
          end
        end

        def model_name
          client = @account.holder_name.gsub(/\s*/, '').classify
          "#{ @user_module }Bank#{ @i }"
        end
      end
    end
  end
end

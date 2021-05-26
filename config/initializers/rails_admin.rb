RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == CancanCan ==
  # config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  def list_info
    field :email
    field :phone
    field :first_name
    field :surname
    field :created_at
  end

  config.included_models = %w{
    User::All

    User::Trouble::NoPhone
    User::Trouble::NoPhoneConfirmed
    User::Trouble::NoProperty
    User::Trouble::NoTenant
    User::Trouble::NoTinkLink
    User::Trouble::NoBankAccount

    User::Success::WithPhone
    User::Success::WithPhoneConfirmed
    User::Success::WithProperty
    User::Success::WithTenant
    User::Success::WithTinkLink
    User::Success::WithBankAccount
  }

  User::Test::Builder.build

  test_fields = %i[
    amount
    category_type
    description
    transaction_date
  ]
  User::Test::Builder.models.each do |model|
    config.included_models << "#{ model }"
    config.model model do
      list do
        sort_by :transaction_date
        test_fields.each do |column|
          field column
        end
      end
      show do
        test_fields.each do |column|
          field column
        end
      end
      edit do
        test_fields.each do |column|
          field column
        end
      end
    end
  end
  config.model User::All do
    list { list_info }
  end

  config.model User::Trouble::NoPhone do
    list { list_info }
  end
  config.model User::Trouble::NoPhoneConfirmed do
    list { list_info }
  end
  config.model User::Trouble::NoTinkLink do
    list { list_info }
  end
  config.model User::Trouble::NoBankAccount do
    list { list_info }
  end
  config.model User::Trouble::NoTenant do
    list { list_info }
  end
  config.model User::Trouble::NoProperty do
    list { list_info }
  end

  config.model User::Success::WithPhone do
    list { list_info }
  end
  config.model User::Success::WithPhoneConfirmed do
    list { list_info }
  end
  config.model User::Success::WithTinkLink do
    list { list_info }
  end
  config.model User::Success::WithBankAccount do
    list { list_info }
  end
  config.model User::Success::WithTenant do
    list { list_info }
  end
  config.model User::Success::WithProperty do
    list { list_info }
  end
end

class ActiveRecord::Base
  include Adminable
end

class RailsAdmin::AbstractModel
  include Adminable
end

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
    # edit
    # delete
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
  end


  config.included_models = %w{
    User::All
    User::PhoneNotConfirmed
    User::TinkNotRegistered
    User::TinkRegistered
  }

  config.model User::All do
    list { list_info }
  end
  config.model User::BankMany do
    list { list_info }
  end
  config.model User::BankSingle do
    list { list_info }
  end
  config.model User::PhoneNotConfirmed do
    list { list_info }
  end
  config.model User::PropertyMany do
    list { list_info }
  end
  config.model User::PropertySingle do
    list { list_info }
  end
  config.model User::TenantNotAdded do
    list { list_info }
  end
  config.model User::TinkNotAuthenticated do
    list { list_info }
  end
  config.model User::TinkNotRegistered do
    list { list_info }
  end
  config.model User::TinkRegistered do
    list { list_info }
  end
end

module AuthHelper
  include Warden::Test::Helpers

  def self.included(base)
    base.let(:headers) { {} }
    base.let(:params) { {} }

    base.before(:each) { Warden.test_mode! }
    base.after(:each) { Warden.test_reset! }
  end

  def sign_in(resource)
    login_as(resource, scope: warden_scope(resource))
  end

  def sign_out(resource)
    logout(warden_scope(resource))
  end

  def auth_headers(user = nil)
    (user || try(:user)).create_new_auth_token.merge({
      'accept' => 'application/json'
    })
  end

  private

  def warden_scope(resource)
    resource.class.name.underscore.to_sym
  end
end

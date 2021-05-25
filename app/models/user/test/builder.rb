module User::Test::Builder
  PHONES = ENV['PHONES']&.split(' ') || %w[+447768333333]

  def self.build
    for phone in PHONES
      user = User.find_by(phone: phone) || User.joins(:saved_transactions).first
      user.saved_transactions.index_by(&:account).each do |account, transaction|
        create_class(user, account, transaction)
      end
    end
  end

  def self.create_class(user, account, transaction)
    klass_name = account.holder_name.gsub(/\s*/, '')
    klass = Class.new(ActiveRecord::Base)
    byebug
    Object.const_set("#{ self }::#{ klass_name }", klass)
  end
end

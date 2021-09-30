module Mock
  def mock(object, method, result)
    @@result = result
    object.define_method(method) { |*args, **params| @@result }
  end
end

RSpec.configure do |config|
  config.include Mock
end

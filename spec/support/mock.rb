def mock(object, method, result)
  @@result = result
  object.define_method(method) { |*args, **params| @@result }
end

# stub_attrs can be used to assign default values for method calls.
# Useful in cases where comparison with nil may occur.
class NullObject
  def initialize(stub_attrs = {})
    @stub_attrs = stub_attrs
  end

  def present? = false
  def empty? = true
  def blank? = true

  def method_missing(*args)
    method_name = args.first

    @stub_attrs.fetch(method_name, nil)
  end

  def respond_to_missing?(*_args)
    true
  end

  def to_s
    nil
  end
end

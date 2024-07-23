require_dependency 'active_model/errors'

module ActiveModel
  class Errors
    # We noticed that the govuk form builder library is accessing errors using
    # strings when the underlying object is a plain Hash with symbols as keys

    # This change makes the errors object more flexible to work with the form builder library
    # by using a HashWithIndifferentAccess object to store the errors
    def messages
      hash = to_hash
      hash.default = EMPTY_ARRAY
      hash.freeze

      # This is the only line that was changed and enables the govuk form builder checkbox fieldset to properly render errors
      HashWithIndifferentAccess.new(hash)
    end
  end
end

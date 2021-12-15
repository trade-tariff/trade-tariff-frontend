module ActiveModelTypes
  # There is currently no good way to handle the fact that
  # the ActiveModel::Attributes module (through Time.utc)
  # propagates an error on unparseable multi parameter date
  # types currently. This is not something that happens within
  # ActiveRecord where the broken date fails validation rather than
  # when being casted.
  #
  # This is the most generic way we can think of to avoid propagating
  # these errors and leave them to be appended to the messages hash as
  # part of the validation callbacks.
  class TariffDate < ActiveModel::Type::Date
    def value_from_multiparameter_assignment(values_hash)
      return unless values_hash[1] && values_hash[2] && values_hash[3]

      values = values_hash.sort.map!(&:last)

      ::Date.civil(*values)
    rescue ArgumentError
      # This needs to be nil to put an empty value in the form
      nil
    end
  end
end

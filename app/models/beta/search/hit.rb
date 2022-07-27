module Beta
  module Search
    class Hit
      include ApiEntity

      attr_accessor :id,
                    :type
    end
  end
end

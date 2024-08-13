module GreenLanes
  class DetermineResultingCategory
    def initialize(categories, cat_1_exempt, cat_2_exempt)
      @categories = categories
      @cat_1_exempt = cat_1_exempt.nil? ? nil : cat_1_exempt == 'true'
      @cat_2_exempt = cat_2_exempt.nil? ? nil : cat_2_exempt == 'true'
    end

    def call
      case @categories
      when [1], [2], [3]
        @categories.first
      when [1, 2, 3]
        handle_all_categories
      when [1, 2]
        handle_cat1_cat2
      when [1, 3]
        handle_cat1_cat3
      when [2, 3]
        handle_cat2_cat3
      else
        raise 'Impossible to determine your result'
      end
    end

    private

    def handle_all_categories
      return 3 if @cat_1_exempt && @cat_2_exempt
      return 2 if @cat_1_exempt

      1
    end

    def handle_cat1_cat2
      return 2 if @cat_1_exempt

      1
    end

    def handle_cat1_cat3
      return 3 if @cat_1_exempt

      1
    end

    def handle_cat2_cat3
      return 3 if @cat_2_exempt

      2
    end
  end
end

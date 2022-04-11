FactoryBot.define do
  factory :kaminari do
    collection { [] }

    initialize_with do
      Kaminari
        .paginate_array(collection, total_count: collection.size)
        .page(1)
        .per(5)
    end
  end
end

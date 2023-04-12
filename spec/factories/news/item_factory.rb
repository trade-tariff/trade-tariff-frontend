FactoryBot.define do
  factory :news_item, class: 'News::Item' do
    transient do
      collection_count { 1 }
    end

    sequence(:id) { |n| n }
    sequence(:slug) { |n| "slug-#{n}" }
    start_date { Time.zone.yesterday }
    sequence(:title) { |n| "News item #{n}" }
    display_style { News::Item::DISPLAY_STYLE_REGULAR }
    show_on_xi { true }
    show_on_uk { true }
    show_on_updates_page { false }
    show_on_home_page { false }
    show_on_banner { false }

    collections do
      attributes_for_list :news_collection, collection_count
    end

    content do
      <<~CONTENT
        This is some **body** content

        1. With
        2. A list
        3. In it
      CONTENT
    end

    trait :uk_only do
      show_on_xi { false }
    end

    trait :xi_only do
      show_on_uk { false }
    end

    trait :home_page do
      show_on_home_page { true }
    end

    trait :banner do
      show_on_banner { true }
    end

    trait :updates_page do
      show_on_updates_page { true }
    end

    trait :with_precis do
      precis { "first paragraph\n\nsecond paragraph" }
    end

    trait :with_subheadings do
      content do
        <<~CONTENT
          ## Second heading

          This is a paragraph

          And Another

          ## Additional second heading

          Paragraph

          ### Third level heading

          * One
          * Two
          * Three
        CONTENT
      end
    end

    trait :with_unsafe_html do
      title { "Title <script>alert('Hello, world!')</script>" }

      content do
        <<~CONTENT
          ## Second heading <script>alert('Hello, world!')</script>

          This is a paragraph
        CONTENT
      end
    end

    trait :with_safe_html do
      title { 'Title <abbr>MFN</abbr>' }

      content do
        <<~CONTENT
          ## Second heading <abbr>MFN</abbr>

          This is a paragraph
        CONTENT
      end
    end
  end
end

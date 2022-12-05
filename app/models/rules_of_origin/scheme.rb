require 'api_entity'

class RulesOfOrigin::Scheme
  include ApiEntity

  collection_path '/rules_of_origin_schemes'

  attr_accessor :scheme_code, :title, :countries, :footnote, :fta_intro,
                :introductory_notes, :unilateral, :cumulation_methods

  has_many :rules, class_name: 'RulesOfOrigin::Rule'
  has_many :links, class_name: 'RulesOfOrigin::Link'
  has_many :proofs, class_name: 'RulesOfOrigin::Proof'
  has_many :articles, class_name: 'RulesOfOrigin::Article'
  has_many :rule_sets, class_name: 'RulesOfOrigin::RuleSet'
  has_one :origin_reference_document, class_name: 'RulesOfOrigin::OriginReferenceDocument'

  class << self
    def for_heading_and_country(heading_code, country_code, opts = {})
      all opts.merge(
        heading_code: heading_code.first(6),
        country_code:,
      )
    end

    def with_duty_drawback_articles(opts = {})
      all opts.merge(filter: { has_article: 'duty-drawback' })
    end
  end

  def article(article)
    articles.find { |a| a.article == article }
  end

  def v2_rules
    rule_sets.flat_map(&:rules)
  end

  def agreement_link
    links.find { |link| link.source == 'scheme' }&.url
  end

  def origin_reference_document_original?
    origin_reference_document.ord_original.present?
  end
end

require 'spec_helper'

RSpec.describe GoodsNomenclatureCodeLinkifier do
  def render(html, service_path: '')
    described_class.new(html, service_path:).render
  end

  def page(html, service_path: '')
    Capybara.string(render(html, service_path:))
  end

  def link_texts(rendered)
    rendered.all('a').map { |link| link.text.gsub(/ \(opens in new tab\)\z/, '') }
  end

  def linked_code_only?(rendered, phrase, code, href)
    rendered.has_text?(phrase) &&
      rendered.has_link?(code, href:) &&
      link_texts(rendered).exclude?(phrase)
  end

  describe '#render' do
    it 'linkifies a chapter keyword reference' do
      rendered = page('<p>goods of Chapter 71</p>')

      expect(linked_code_only?(rendered, 'Chapter 71', '71', '/search?q=71')).to be(true)
    end

    it 'linkifies single-digit chapters' do
      rendered = page('<p>Heading 1005 does not cover sweetcorn (Chapter 7)</p>')

      expect(linked_code_only?(rendered, 'Chapter 7', '7', '/search?q=07')).to be(true)
    end

    it 'linkifies heading codes using mixed separators', :aggregate_failures do
      rendered = page('<p>(headings 3207 to 3210, 3212, 3213 or 3215)</p>')

      expect(rendered).to have_link('3207', href: '/search?q=3207')
      expect(rendered).to have_link('3210', href: '/search?q=3210')
      expect(rendered).to have_link('3212', href: '/search?q=3212')
      expect(rendered).to have_link('3213', href: '/search?q=3213')
      expect(rendered).to have_link('3215', href: '/search?q=3215')
    end

    it 'linkifies longer goods code references at the end of a sentence' do
      expect(page('<p>commodity 0101210000.</p>')).to have_link('0101210000', href: '/search?q=0101210000')
    end

    it 'linkifies codes followed by a colon' do
      rendered = page('<p>for the purposes of code 0202 20 10: forequarters</p>')

      expect(rendered).to have_link('0202 20 10', href: '/search?q=02022010')
        .and have_no_link(href: '/search?q=10')
    end

    it 'linkifies ten-digit codes with compact middle spacing' do
      rendered = page('<p>Code 2404 1200 90 applies.</p>')

      expect(rendered).to have_link('2404 1200 90', href: '/search?q=2404120090')
        .and have_no_link(href: '/search?q=1200')
    end

    it 'linkifies eight-digit codes with compact middle spacing' do
      rendered = page('<p>codes 2710 2011 to 2710 2090</p>')

      expect(rendered).to have_link('2710 2011', href: '/search?q=27102011')
        .and have_link('2710 2090', href: '/search?q=27102090')
        .and have_no_link(href: '/search?q=2011')
    end

    it 'supports non-breaking spaces around codes' do
      rendered = page("<p>For subheadings 8549 11\u00A0to 8549 19\u00A0, spent cells are covered.</p>")

      expect(rendered).to have_link('8549 11', href: '/search?q=854911')
        .and have_link('8549 19', href: '/search?q=854919')
        .and have_no_link(href: '/search?q=11')
        .and have_no_link(href: '/search?q=19')
    end

    it 'linkifies continuation chapters in lists' do
      rendered = page('<p>goods of Chapter 39, 40 or 63.</p>')

      expect(link_texts(rendered)).to eq(%w[39 40 63])
    end

    it 'does not linkify decimal numbers' do
      expect(page('<p>width exceeds 10.5mm</p>')).not_to have_link('10')
    end

    it 'does not linkify percentages' do
      rendered = page('<p>not more than 10 % of chromium and 30% of manganese</p>')

      expect(rendered).to have_no_link('10')
        .and have_no_link('30')
    end

    it 'does not linkify quantities' do
      rendered = page('<p>at least 10 times the thickness, exceeds 15 mm but not 52 mm, under a current of 50 Hz.</p>')

      expect(rendered).to have_no_link('10')
        .and have_no_link('15')
        .and have_no_link('52')
        .and have_no_link('50')
    end

    it 'does not linkify legal references' do
      rendered = page('<p>Article 45 of Regulation (EU) 33/2019.</p>')

      expect(rendered).to have_no_link('45')
        .and have_no_link('33')
    end

    it 'does not linkify standard references' do
      rendered = page('<p>ISO 8069:2005 method and EN ISO 3104 method.</p>')

      expect(rendered).to have_no_link('8069')
        .and have_no_link('2005')
        .and have_no_link('3104')
    end

    it 'does not linkify years' do
      rendered = page('<p>The Seed Potatoes Regulations 1991 and Cereal Seeds Regulation 1974 apply.</p>')

      expect(rendered).to have_no_link('1991')
        .and have_no_link('1974')
    end

    it 'does not double-linkify existing links', :aggregate_failures do
      html = '<p><a href="/foo">3606</a> and chapter 71</p>'
      rendered = page(html)

      expect(rendered).to have_link('3606', href: '/foo')
      expect(rendered).to have_link('71', href: '/search?q=71')
      expect(rendered).not_to have_css('a a')
    end

    it 'adds the xi service path when rendering in xi context' do
      expect(page('<p>Chapter 71</p>', service_path: '/xi')).to have_link('71', href: '/xi/search?q=71')
    end

    it 'marks generated links as new-tab GOV.UK links', :aggregate_failures do
      rendered = render('<p>Chapter 71</p>')

      expect(rendered).to include('class="govuk-link"')
      expect(rendered).to include('target="_blank"')
      expect(rendered).to include('rel="noopener noreferrer"')
      expect(rendered).to include('<span class="govuk-visually-hidden"> (opens in new tab)</span>')
    end
  end
end

require 'spec_helper'

RSpec.describe GoodsNomenclatureCodeLinkifier do
  def render(html, service_path: '')
    described_class.new(html, service_path:).render
  end

  def page(html, service_path: '')
    Capybara.string(render(html, service_path:))
  end

  describe '#render' do
    it 'linkifies a chapter keyword reference' do
      expect(page('<p>goods of Chapter 71</p>')).to have_link('Chapter 71', href: '/search?q=71')
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

    it 'does not linkify decimal numbers' do
      expect(page('<p>width exceeds 10.5mm</p>')).not_to have_link('10')
    end

    it 'does not double-linkify existing links', :aggregate_failures do
      html = '<p><a href="/foo">3606</a> and chapter 71</p>'
      rendered = page(html)

      expect(rendered).to have_link('3606', href: '/foo')
      expect(rendered).to have_link('chapter 71', href: '/search?q=71')
      expect(rendered).not_to have_css('a a')
    end

    it 'adds the xi service path when rendering in xi context' do
      expect(page('<p>Chapter 71</p>', service_path: '/xi')).to have_link('Chapter 71', href: '/xi/search?q=71')
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

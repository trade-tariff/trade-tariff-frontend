import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['tabs', 'tab', 'keywordSection', 'guidedSection', 'hiddenField']
  static values = { initialMode: { type: String, default: 'keyword' } }

  connect() {
    this.tabsTarget.hidden = false
    this.tabTargets.forEach(tab => {
      const panel = this[`${tab.dataset.mode}SectionTarget`]
      panel.setAttribute('role', 'tabpanel')
      panel.setAttribute('aria-labelledby', tab.id)
    })
    const navigation = window.performance.getEntriesByType?.('navigation')[0]
    const linkedMode = window.location.hash === '#ai-search-panel' && !this.element.querySelector('.govuk-error-summary')
      ? 'guided' : this.initialModeValue
    this.#setMode(navigation?.type === 'reload' ? 'keyword' : linkedMode)
    this.observer = new MutationObserver(() => this.#setMode(this.mode))
    this.observer.observe(this.element, { childList: true, subtree: true })
  }

  disconnect() {
    this.observer.disconnect()
  }

  select(event) {
    event.preventDefault()
    this.#setMode(event.currentTarget.dataset.mode)
  }

  navigate(event) {
    const tabs = this.tabTargets
    const current = tabs.indexOf(event.currentTarget)
    const positions = {
      ArrowRight: (current + 1) % tabs.length,
      ArrowLeft: (current + tabs.length - 1) % tabs.length,
      ' ': current,
      Home: 0,
      End: tabs.length - 1,
    }
    if (!(event.key in positions)) return

    event.preventDefault()
    const tab = tabs[positions[event.key]]
    this.#setMode(tab.dataset.mode)
    tab.focus()
  }

  #setMode(mode) {
    this.mode = mode
    this.hiddenFieldTarget.value = (mode === 'guided').toString()
    this.tabTargets.forEach(tab => {
      const selected = tab.dataset.mode === mode
      tab.setAttribute('aria-selected', selected.toString())
      tab.closest('.govuk-tabs__list-item')?.classList.toggle('govuk-tabs__list-item--selected', selected)
      tab.tabIndex = selected ? 0 : -1
    })
    for (const name of ['keyword', 'guided']) {
      const section = this[`${name}SectionTarget`]
      section.hidden = name !== mode
      section.querySelectorAll('input, textarea, select, button').forEach(input => {
        input.disabled = name !== mode
      })
    }
    this.#scopeSummaryErrors()
    this.element.querySelectorAll('[data-search-mode-error]').forEach(error => {
      error.hidden = error.dataset.searchModeError !== mode
    })
    this.element.querySelectorAll('.govuk-error-summary:not([data-search-mode-error])').forEach(summary => {
      summary.hidden = !Array.from(summary.querySelectorAll('li')).some(item => !item.hidden)
    })
  }

  #scopeSummaryErrors() {
    this.element.querySelectorAll('.govuk-error-summary li:not([data-search-mode-error])').forEach(item => {
      const href = item.querySelector('a')?.getAttribute('href')
      if (!href?.startsWith('#') || href.length === 1) return

      const target = Array.from(this.element.querySelectorAll('[id]')).find(element => element.id === href.slice(1))
      if (!target) return

      for (const mode of ['keyword', 'guided']) {
        if (this[`${mode}SectionTarget`].contains(target)) item.dataset.searchModeError = mode
      }
    })
  }

}

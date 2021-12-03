export default class SearchBanner {
  static connectAll() {
    const elements = document.querySelectorAll('.hott-search-banner');

    for(const element of elements) {
      new SearchBanner(element)
    }
  }

  constructor(element) {
    this.element = element ;
    this.connectToggleButton() ;
  }

  connectToggleButton() {
    const button = this.element.querySelector('button.hott-search-banner__toggle') ;
    button.addEventListener('click', this.toggle.bind(this)) ;
  }

  toggle() {
    this.element.classList.toggle('hott-search-banner--open') ;
  }
}

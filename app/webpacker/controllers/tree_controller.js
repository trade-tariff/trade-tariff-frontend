import {Controller} from '@hotwired/stimulus';
const CookieManager = require('../src/javascripts/cookie-manager.js').default;

export default class extends Controller {
  static targets = [
    'openAll',
    'closeAll',
    'parentNode',
    'commodityNode',
    'commodityInfo',
  ];

  connect() {
    this.cookieManager = new CookieManager();
    this.#initializeTree();

    if (this.hasCommodityInfoTargets) {
      window.addEventListener('resize', () => {
        return this.#adjustCommodityInfoHeights();
      });
    }
  }

  toggleNode(event) {
    event.preventDefault();
    const commodityNode = event.currentTarget;
    const childList = commodityNode.parentElement.querySelector('ul');

    if (childList.getAttribute('aria-hidden') == 'true') {
      this.#openBranch(commodityNode, childList);
    } else {
      this.#closeBranch(commodityNode, childList);
    }
  }

  hoverOnNode(event) {
    event.currentTarget.classList.add('description-hover');
  }

  hoverOffNode(event) {
    event.currentTarget.classList.remove('description-hover');
  }

  openAll(event) {
    event.preventDefault();

    if (this.cookieManager.rememberSettings()) {
      this.cookieManager.setCookiesTreeOpenClosedDefault({'value': 'open'});
    }

    this.#doOpenAll();
    this.#adjustCommodityInfoHeights();
  }

  closeAll(event) {
    event.preventDefault();

    if (this.cookieManager.rememberSettings()) {
      this.cookieManager.setCookiesTreeOpenClosedDefault({'value': 'close'});
    }

    this.#doCloseAll();
    this.#adjustCommodityInfoHeights();
  }

  #openBranch(branch, childList) {
    childList.setAttribute('aria-hidden', 'false');
    branch.classList.add('open');
    branch.setAttribute('title', 'Click to open');
    branch.setAttribute('aria-expanded', 'true');

    this.#focusChild(childList);
  }

  #closeBranch(branch, childList) {
    childList.setAttribute('aria-hidden', 'true');
    branch.classList.remove('open');
    branch.setAttribute('title', 'Click to close');
    branch.setAttribute('aria-expanded', 'false');

    this.#focusChild(childList);
  }

  #focusChild(childList) {
    const focusTarget = childList.tagName === 'UL' ? childList.querySelector('li') : childList.querySelector('ul li');

    if (focusTarget) {
      focusTarget.focus();
    }
  }

  #initializeTree() {
    if (this.cookieManager.getCookiesTreeOpenClosedDefault()) {
      const value = this.cookieManager.getCookiesTreeOpenClosedDefault();

      if (value === 'open') {
        this.#doOpenAll();
      } else {
        this.#doCloseAll();
      }
    }
  }


  #doOpenAll() {
    this.parentNodeTargets.forEach((parentNode, idx) => {
      this.#openBranch(
          this.commodityNodeTargets[idx],
          parentNode.querySelector('ul'),
      );
    });
  }

  #doCloseAll() {
    this.parentNodeTargets.forEach((parentNode, idx) => {
      this.#closeBranch(
          this.commodityNodeTargets[idx],
          parentNode.querySelector('ul'),
      );
    });
  }

  #adjustCommodityInfoHeights() {
    const windowWidth = window.innerWidth;

    this.commodityInfoTargets.forEach((element) => {
      element.style.height = 'auto';

      if (windowWidth >= 1100) {
        element.style.height = `${element.parentElement.offsetHeight}px`;
      }
    });
  }
}

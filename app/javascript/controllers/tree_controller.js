import {Controller} from '@hotwired/stimulus';

export default class extends Controller {
  static targets = [
    'openAll',
    'closeAll',
    'parentNode',
    'commodityNode',
    'commodityInfo',
  ];

  connect() {
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
    this.#doOpenAllRecursive();
    this.#adjustCommodityInfoHeights();
  }

  closeAll(event) {
    event.preventDefault();
    this.#doCloseAllRecursive();
    this.#adjustCommodityInfoHeights();
  }

  #openBranch(branch, childList) {
    childList.setAttribute('aria-hidden', 'false');
    branch.classList.add('open');
    branch.setAttribute('title', 'Click to close');
    branch.setAttribute('aria-expanded', 'true');

    this.#focusChild(childList);
  }

  #closeBranch(branch, childList) {
    childList.setAttribute('aria-hidden', 'true');
    branch.classList.remove('open');
    branch.setAttribute('title', 'Click to open');
    branch.setAttribute('aria-expanded', 'false');

    this.#focusChild(childList);
  }

  #focusChild(childList) {
    const focusTarget = childList.tagName === 'UL' ? childList.querySelector('li') : childList.querySelector('ul li');

    if (focusTarget) {
      focusTarget.focus();
    }
  }

  #doOpenAllRecursive() {
    // Find all nodes with children (not just top-level targets) and open them recursively
    const allParentNodes = this.element.querySelectorAll('[data-tree-target="parentNode"]');
    allParentNodes.forEach((parentNode) => {
      const commodityNode = parentNode.querySelector('[data-tree-target="commodityNode"]');
      const childList = parentNode.querySelector('ul');
      if (commodityNode && childList) {
        this.#openBranch(commodityNode, childList);
      }
    });
  }

  #doCloseAllRecursive() {
    // Find all nodes with children (not just top-level targets) and close them recursively
    const allParentNodes = this.element.querySelectorAll('[data-tree-target="parentNode"]');
    allParentNodes.forEach((parentNode) => {
      const commodityNode = parentNode.querySelector('[data-tree-target="commodityNode"]');
      const childList = parentNode.querySelector('ul');
      if (commodityNode && childList) {
        this.#closeBranch(commodityNode, childList);
      }
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

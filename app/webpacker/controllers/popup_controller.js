import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["popup", "mask", "inner", "title", "close"];

  connect() {
    console.log("Popup controller connected");
  }

  open(event) {
    event.preventDefault();
    const popupRef = event.currentTarget.dataset.popupRef;
    const popupElement = document.querySelector(`[data-popup-id="${popupRef}"]`);

    if (popupElement) {
      this.adapt(popupElement);
      this.showPopup(popupElement);
      this.scrollInPopup(true);
    }
  }

  adapt(popupElement) {
    const contentElement = document.querySelector(`[data-popup="${popupElement.dataset.popupId}"]`).innerHTML;
    this.innerTarget.innerHTML = contentElement;

    this.titleTarget.setAttribute('tabindex', 0);
    this.titleTarget.focus();
  }

  showPopup(popupElement) {
    popupElement.style.display = 'block';
    popupElement.setAttribute('aria-hidden', 'false');

    this.maskTarget.style.display = 'block';
    this.maskTarget.addEventListener('click', this.close.bind(this));
  }

  close(event) {
    event.preventDefault();
    const popupElement = this.popupTarget;

    popupElement.style.display = 'none';
    popupElement.setAttribute('aria-hidden', 'true');
    this.maskTarget.style.display = 'none';

    this.scrollInPopup(false);
    event.currentTarget.focus();
  }

  scrollInPopup(scrollPopup) {
    document.body.style.overflow = scrollPopup ? 'hidden' : '';
  }
}

/* This controller is taken and adapted from the stimulus demo example here:
   https://tighten.com/insights/stimulus-101-building-a-modal/
   (renamed demo to anchor for context)
*/

/* global $ */

import {Controller} from 'stimulus';

export default class extends Controller {
  static targets = ['modal'];

  initialize() {
    // All the HTML for modal pop-ups are generated already and need to be hidden on the page
    $('#import-measure-references, #export-measure-references').hide();
    document.addEventListener('click', this.handleClickOutsideOpenModal.bind(this));
    document.addEventListener('keydown', this.handleEscapePressWithOpenModal.bind(this));
    this.isModalOpen = false;
  }

  connect() {
    // This will check the anchor tag in the URL and launch the modal automatically if it matches the order number
    const anchorOrderNumber = window.location.hash && window.location.hash.slice(1);
    const anchorLink = this.element.querySelector('a');
    if (anchorLink) {
      const modalOrderNumber = anchorLink.dataset.modalRef;
      if (modalOrderNumber === anchorOrderNumber) {
        this.launchModal({currentTarget: anchorLink});
      }
    }
  }

  launchModal(event) {
    const modalRef = event.currentTarget.dataset.modalRef;

    // this stops the page scrolling to the top when the modal is closed
    if (event.isTrusted) {
      event.preventDefault();
    }

    // Find the hidden HTML element with the corresponding data-popup value
    const popupContent = document.querySelector(`[data-popup='${modalRef}']`);

    if (!popupContent) {
      console.error(`No content found for modal reference: ${modalRef}`);
      return;
    }

    // ensure all modals are loaded before opening
    setTimeout(() => {
      this.modalController = this.application.getControllerForElementAndIdentifier(
          this.modalTarget,
          'modal',
      );
      if (this.modalController) {
        this.isModalOpen = true;
        this.modalController.open(popupContent.innerHTML);
      } else {
        console.error('Modal controller could not be found');
      }
    }, 0);
  }

  handleClickOutsideOpenModal(event) {
    if (this.isModalOpen && !this.modalTarget.contains(event.target) && !event.target.closest('[data-modal-ref]')) {
      this.modalController.close(event);
      this.isModalOpen = false;
    }
  }

  handleEscapePressWithOpenModal(event) {
    if (event.key === 'Escape' && this.isModalOpen) {
      this.modalController.close(event);
      this.isModalOpen = false;
    }
  }
}

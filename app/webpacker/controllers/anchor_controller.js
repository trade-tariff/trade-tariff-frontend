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

    const anchorOrderNumber = window.location.hash;
    const modalOrderNumber = this.modalTarget.data.get('order-number');

    if (modalOrderNumber === anchorOrderNumber) {
      const event = new Event('click');
      this.launchModal(event);
    }
  }

  launchModal(event) {
    event.preventDefault();
    const modalRef = event.currentTarget.dataset.modalRef;
    // Find the hidden HTML element with the corresponding data-popup value
    const popupContent = document.querySelector(`[data-popup='${modalRef}']`);

    if (!popupContent) {
      console.error(`No content found for modal reference: ${modalRef}`);
      return;
    }

    this.modalController = this.application.getControllerForElementAndIdentifier(
        this.modalTarget,
        'modal');

    this.isModalOpen = true;
    this.modalController.open(popupContent.innerHTML);
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

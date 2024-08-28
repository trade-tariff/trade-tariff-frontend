import {Controller} from 'stimulus';

export default class extends Controller {
  open(content) {
    // Clear existing modal content, if any
    this.element.innerHTML = '';

    // Create and inject the modal content structure
    const modalContent = `
            <div class="info-content">
                <h2 id="dialog-title" data-popup-target="title" class="govuk-visually-hidden">Conditions</h2>
                <p class="close"><a href="#" data-popup-target="close" data-action="click->modal#close">Close</a></p>
                <div class="info-inner" data-popup-target="inner"></div>
            </div>
        `;
    // Inject the structure into the modal element
    this.element.insertAdjacentHTML('afterbegin', modalContent);

    // Inject the content into the info-inner div
    const infoInner = this.element.querySelector('.info-inner');
    infoInner.innerHTML = content;

    // Add the modal open class to the body
    document.body.classList.add('modal-open');

    // Display the modal
    this.element.style.display = 'block';
    this.element.classList.add('show');
    this.element.classList.add('modal-border');

    // Create and append the backdrop
    const backdrop = document.createElement('div');
    backdrop.className = 'modal-backdrop fade show';
    document.body.appendChild(backdrop);

    // Set focus on the dialog title for accessibility
    const dialogTitle = this.element.querySelector('#dialog-title');
    dialogTitle.setAttribute('tabindex', 0);
    dialogTitle.focus();
  }

  close(event) {
    event.preventDefault();

    // Hide the modal
    this.element.style.display = 'none';
    this.element.classList.remove('show');
    this.element.classList.remove('modal-border');

    // Remove the backdrop
    const backdrop = document.querySelector('.modal-backdrop');
    if (backdrop) {
      backdrop.remove();
    }

    // Remove the modal open class from the body
    document.body.classList.remove('modal-open');

    // Clear the modal content
    this.element.innerHTML = '';
  }
}

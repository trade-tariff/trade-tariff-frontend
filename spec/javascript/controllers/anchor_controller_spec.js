import {Application} from '@hotwired/stimulus';
import AnchorController from 'anchor_controller';
import ModalController from 'modal_controller';

describe('AnchorController', () => {
  let application;
  let anchorElement;
  let modalElement;

  beforeEach(() => {
    document.body.innerHTML = `
      <div data-controller="anchor">
        <a href="#" data-action="click->anchor#launchModal" data-modal-ref="test-modal" role="button">Open Modal</a>
        <div id="modal" class="modal tariff-info" data-controller="modal" data-anchor-target="modal"></div>
        <div data-popup="test-modal" style="display: none;">Modal Content for Test</div>
      </div>
    `;

    application = Application.start();
    application.register('anchor', AnchorController);
    application.register('modal', ModalController);

    anchorElement = document.querySelector('[data-controller="anchor"]');
    modalElement = document.querySelector('#modal');
  });

  afterEach(() => {
    application.stop();
  });

  it('launchModal method opens the modal with the correct content', async () => {
    const anchorController = application.getControllerForElementAndIdentifier(anchorElement, 'anchor');
    const modalController = application.getControllerForElementAndIdentifier(modalElement, 'modal');

    jest.spyOn(modalController, 'open');

    const event = {
      preventDefault: jest.fn(),
      currentTarget: anchorElement.querySelector('a'),
      isTrusted: true,
    };

    anchorController.launchModal(event);

    // Wait for the modal to be opened
    await new Promise((resolve) => setTimeout(resolve, 0));
    expect(event.preventDefault).toHaveBeenCalled();
    expect(modalController.open).toHaveBeenCalledWith('Modal Content for Test');
    expect(modalElement.classList.contains('show')).toEqual(true);
  });

  it('handleClickOutsideOpenModal method closes the modal when clicking outside', async () => {
    const anchorController = application.getControllerForElementAndIdentifier(anchorElement, 'anchor');
    const modalController = application.getControllerForElementAndIdentifier(modalElement, 'modal');

    const event = {
      preventDefault: jest.fn(),
      currentTarget: anchorElement.querySelector('a'),
      isTrusted: true,
    };
    anchorController.launchModal(event);

    await new Promise((resolve) => setTimeout(resolve, 0));

    jest.spyOn(modalController, 'close');

    const outsideClickEvent = new MouseEvent('click', {
      bubbles: true,
      cancelable: true,
    });

    document.body.dispatchEvent(outsideClickEvent);
    anchorController.modalController = modalController;
    anchorController.handleClickOutsideOpenModal(outsideClickEvent);

    expect(modalController.close).toHaveBeenCalled();
    expect(anchorController.isModalOpen).toBe(false);
    expect(modalElement.classList.contains('show')).toEqual(false);
  });

  it('handleEscapePressWithOpenModal method closes the modal on Escape key press', async () => {
    const anchorController = application.getControllerForElementAndIdentifier(anchorElement, 'anchor');
    const modalController = application.getControllerForElementAndIdentifier(modalElement, 'modal');

    const event = {
      preventDefault: jest.fn(),
      currentTarget: anchorElement.querySelector('a'),
      isTrusted: true,
    };
    anchorController.launchModal(event);
    await new Promise((resolve) => setTimeout(resolve, 0));

    jest.spyOn(modalController, 'close');

    const escapeKeyPressEvent = new KeyboardEvent('keydown', {
      key: 'Escape',
      bubbles: true,
      cancelable: true,
    });

    anchorController.handleEscapePressWithOpenModal(escapeKeyPressEvent);

    expect(modalController.close).toHaveBeenCalled();
    expect(anchorController.isModalOpen).toBe(false);
    expect(modalElement.classList.contains('show')).toEqual(false);
  });
});

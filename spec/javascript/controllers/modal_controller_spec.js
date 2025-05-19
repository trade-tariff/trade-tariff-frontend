import {Application} from '@hotwired/stimulus';
import ModalController from '../../../app/javascript/controllers/modal_controller';

describe('ModalController', () => {
  let application;
  let element;

  beforeEach(() => {
    document.body.innerHTML = `
      <div id="modal" class="modal tariff-info" data-controller="modal"></div>
    `;

    application = Application.start();
    application.register('modal', ModalController);

    element = document.querySelector('#modal');
  });

  afterEach(() => {
    application.stop();
  });

  it('opens the modal with provided content', () => {
    const controller = application.getControllerForElementAndIdentifier(element, 'modal');

    controller.open('<p>Modal Content</p>');

    expect(element.classList.contains('show')).toEqual(true);
    expect(element.textContent).toContain('Modal Content');
  });

  it('closes the modal when close is called', () => {
    const controller = application.getControllerForElementAndIdentifier(element, 'modal');

    controller.open('<p>Modal Content</p>');

    const event = new Event('click');
    jest.spyOn(event, 'preventDefault');

    controller.close(event);

    expect(event.preventDefault).toHaveBeenCalled();
    expect(element.style.display).toBe('none');
    expect(element.classList).not.toContain('show');
    expect(document.body.classList).not.toContain('modal-open');
    const backdrop = document.querySelector('.modal-backdrop');
    expect(backdrop).toBeNull();
    expect(element.innerHTML).toBe('');
  });

  it('removes the backdrop when the modal is closed', () => {
    const controller = application.getControllerForElementAndIdentifier(element, 'modal');

    controller.open('<p>Modal Content</p>');

    const event = new Event('click');
    jest.spyOn(event, 'preventDefault');

    controller.close(event);

    expect(event.preventDefault).toHaveBeenCalled();
    const backdrop = document.querySelector('.modal-backdrop');
    expect(backdrop).toBeNull();
  });
});

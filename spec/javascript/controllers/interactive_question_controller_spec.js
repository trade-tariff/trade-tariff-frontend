import {Application} from '@hotwired/stimulus';
import InteractiveQuestionController from '../../../app/javascript/controllers/interactive_question_controller';

describe('InteractiveQuestionController', () => {
  let application;

  beforeEach(() => {
    document.body.innerHTML = `
      <div data-controller="interactive-question">
        <div data-interactive-question-target="form" id="form">
          <form data-action="submit->interactive-question#submitWithThinking">
            <input type="radio" id="unknown" data-action="change->interactive-question#selectUnknown">
            <button type="submit">Submit</button>
          </form>
        </div>
        <div data-interactive-question-target="thinking" id="thinking" class="govuk-!-display-none">
          <p>Collecting information...</p>
        </div>
        <div data-interactive-question-target="dontKnow" id="dont-know" class="govuk-!-display-none">
          <p>We can't suggest a tariff code yet</p>
          <button data-action="interactive-question#goBack">Go back</button>
        </div>
      </div>
    `;

    application = Application.start();
    application.register('interactive-question', InteractiveQuestionController);
  });

  afterEach(() => {
    application.stop();
    jest.useRealTimers();
  });

  describe('#selectUnknown', () => {
    beforeEach(() => {
      jest.useFakeTimers();
    });

    it('hides the form after delay', () => {
      const form = document.querySelector('#form');
      const radio = document.querySelector('#unknown');

      const event = new Event('change', {bubbles: true});
      radio.dispatchEvent(event);

      expect(form.classList.contains('govuk-!-display-none')).toBe(false);

      jest.advanceTimersByTime(150);
      expect(form.classList.contains('govuk-!-display-none')).toBe(true);
    });

    it('shows the dont know page after delay', () => {
      const dontKnow = document.querySelector('#dont-know');
      const radio = document.querySelector('#unknown');

      const event = new Event('change', {bubbles: true});
      radio.dispatchEvent(event);

      expect(dontKnow.classList.contains('govuk-!-display-none')).toBe(true);

      jest.advanceTimersByTime(150);
      expect(dontKnow.classList.contains('govuk-!-display-none')).toBe(false);
    });
  });

  describe('#goBack', () => {
    beforeEach(() => {
      jest.useFakeTimers();
    });

    it('hides the dont know page and shows the form', () => {
      const form = document.querySelector('#form');
      const dontKnow = document.querySelector('#dont-know');
      const radio = document.querySelector('#unknown');

      // First trigger "I don't know"
      const changeEvent = new Event('change', {bubbles: true});
      radio.dispatchEvent(changeEvent);
      jest.advanceTimersByTime(150);

      expect(form.classList.contains('govuk-!-display-none')).toBe(true);
      expect(dontKnow.classList.contains('govuk-!-display-none')).toBe(false);

      // Now go back
      const goBackButton = dontKnow.querySelector('button');
      goBackButton.click();

      expect(form.classList.contains('govuk-!-display-none')).toBe(false);
      expect(dontKnow.classList.contains('govuk-!-display-none')).toBe(true);
    });
  });

  describe('#submitWithThinking', () => {
    it('hides the form and shows the thinking screen', () => {
      const form = document.querySelector('#form');
      const thinking = document.querySelector('#thinking');
      const formEl = document.querySelector('form');

      const event = new Event('submit', {bubbles: true, cancelable: true});
      formEl.dispatchEvent(event);

      expect(form.classList.contains('govuk-!-display-none')).toBe(true);
      expect(thinking.classList.contains('govuk-!-display-none')).toBe(false);
    });
  });
});

import {Application} from '@hotwired/stimulus';
import InteractiveQuestionController from '../../../app/javascript/controllers/interactive_question_controller';

describe('InteractiveQuestionController', () => {
  let application;

  beforeEach(() => {
    document.body.innerHTML = `
      <div data-controller="interactive-question">
        <div data-interactive-question-target="form" id="form">
          <input type="radio" id="unknown" data-action="change->interactive-question#selectUnknown">
        </div>
        <div data-interactive-question-target="results" id="results" class="govuk-!-display-none">
          <p>Pre-rendered results</p>
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

      // Before timeout
      expect(form.classList.contains('govuk-!-display-none')).toBe(false);

      // After timeout
      jest.advanceTimersByTime(150);
      expect(form.classList.contains('govuk-!-display-none')).toBe(true);
    });

    it('shows the results after delay', () => {
      const results = document.querySelector('#results');
      const radio = document.querySelector('#unknown');

      const event = new Event('change', {bubbles: true});
      radio.dispatchEvent(event);

      // Before timeout
      expect(results.classList.contains('govuk-!-display-none')).toBe(true);

      // After timeout
      jest.advanceTimersByTime(150);
      expect(results.classList.contains('govuk-!-display-none')).toBe(false);
    });
  });
});

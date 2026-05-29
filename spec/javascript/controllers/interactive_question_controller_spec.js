import {Application} from '@hotwired/stimulus';
import InteractiveQuestionController from '../../../app/javascript/controllers/interactive_question_controller';

describe('InteractiveQuestionController', () => {
  let application;

  beforeEach(() => {
    document.body.innerHTML = `
      <main id="content">
      <div data-controller="interactive-question">
        <div data-interactive-question-target="pageHeader" id="page-header">
          <span>UK Integrated Online Tariff</span>
        </div>
        <div data-interactive-question-target="header" id="header">
          <h1>Search for a commodity</h1>
          <p>We need to ask you some questions about the products.</p>
        </div>
        <div data-interactive-question-target="form" id="form">
          <form data-action="submit->interactive-question#submitWithThinking">
            <input type="radio" id="known" name="interactive_search_form[answer]" value="Haddock">
            <input type="radio" id="unknown" name="interactive_search_form[answer]" value="I don't know">
            <button type="submit">Submit</button>
          </form>
        </div>
        <div data-interactive-question-target="thinking" id="thinking" class="govuk-!-display-none">
          <span>UK Integrated Online Tariff</span>
          <h1>Search for a commodity</h1>
          <p>Collecting information...</p>
        </div>
        <div data-interactive-question-target="dontKnow" id="dont-know" class="govuk-!-display-none">
          <p>We can't suggest a tariff code yet</p>
          <button data-action="interactive-question#goBack">Go back</button>
        </div>
      </div>
      </main>
    `;

    application = Application.start();
    application.register('interactive-question', InteractiveQuestionController);
  });

  afterEach(() => {
    application.stop();
    jest.useRealTimers();
  });

  describe('selecting the unknown option', () => {
    beforeEach(() => {
      jest.useFakeTimers();
    });

    it('does not hide the header and form before the user submits the answer', () => {
      const header = document.querySelector('#header');
      const form = document.querySelector('#form');
      const dontKnow = document.querySelector('#dont-know');
      const radio = document.querySelector('#unknown');

      const event = new Event('change', {bubbles: true});
      radio.dispatchEvent(event);

      expect(header.classList.contains('govuk-!-display-none')).toBe(false);
      expect(form.classList.contains('govuk-!-display-none')).toBe(false);
      expect(dontKnow.classList.contains('govuk-!-display-none')).toBe(true);

      jest.advanceTimersByTime(150);

      expect(header.classList.contains('govuk-!-display-none')).toBe(false);
      expect(form.classList.contains('govuk-!-display-none')).toBe(false);
      expect(dontKnow.classList.contains('govuk-!-display-none')).toBe(true);
    });
  });

  describe('#goBack', () => {
    beforeEach(() => {
      jest.useFakeTimers();
    });

    it('hides the dont know page and shows the header and form', () => {
      const header = document.querySelector('#header');
      const form = document.querySelector('#form');
      const dontKnow = document.querySelector('#dont-know');
      const radio = document.querySelector('#unknown');
      const formEl = document.querySelector('form');

      radio.checked = true;
      formEl.dispatchEvent(new Event('submit', {bubbles: true, cancelable: true}));

      expect(header.classList.contains('govuk-!-display-none')).toBe(true);
      expect(form.classList.contains('govuk-!-display-none')).toBe(true);
      expect(dontKnow.classList.contains('govuk-!-display-none')).toBe(false);

      // Now go back
      const goBackButton = dontKnow.querySelector('button');
      goBackButton.click();

      expect(header.classList.contains('govuk-!-display-none')).toBe(false);
      expect(form.classList.contains('govuk-!-display-none')).toBe(false);
      expect(dontKnow.classList.contains('govuk-!-display-none')).toBe(true);
    });
  });

  describe('#submitWithThinking', () => {
    let submitSpy;

    beforeEach(() => {
      jest.useFakeTimers();
      submitSpy = jest.spyOn(HTMLFormElement.prototype, 'submit').mockImplementation(() => {});
    });

    afterEach(() => {
      submitSpy.mockRestore();
    });

    it('hides the form and shows the thinking screen', () => {
      const header = document.querySelector('#header');
      const pageHeader = document.querySelector('#page-header');
      const form = document.querySelector('#form');
      const thinking = document.querySelector('#thinking');
      const formEl = document.querySelector('form');

      const event = new Event('submit', {bubbles: true, cancelable: true});
      formEl.dispatchEvent(event);

      expect(pageHeader.classList.contains('govuk-!-display-none')).toBe(true);
      expect(header.classList.contains('govuk-!-display-none')).toBe(true);
      expect(form.classList.contains('govuk-!-display-none')).toBe(true);
      expect(thinking.classList.contains('govuk-!-display-none')).toBe(false);
      expect(thinking.textContent).toContain('Search for a commodity');
      expect(thinking.textContent).toContain('Collecting information...');
      expect(thinking.textContent).not.toContain('Searching for commodity codes');
    });

    it('submits the form after the thinking screen has rendered', () => {
      const formEl = document.querySelector('form');

      formEl.dispatchEvent(new Event('submit', {bubbles: true, cancelable: true}));

      expect(submitSpy).not.toHaveBeenCalled();

      jest.runOnlyPendingTimers();

      expect(submitSpy).toHaveBeenCalledWith();
    });

    it('shows the dont know page after the unknown answer is submitted without fetching', () => {
      const header = document.querySelector('#header');
      const form = document.querySelector('#form');
      const thinking = document.querySelector('#thinking');
      const dontKnow = document.querySelector('#dont-know');
      const radio = document.querySelector('#unknown');
      const formEl = document.querySelector('form');

      radio.checked = true;
      formEl.dispatchEvent(new Event('submit', {bubbles: true, cancelable: true}));

      expect(header.classList.contains('govuk-!-display-none')).toBe(true);
      expect(form.classList.contains('govuk-!-display-none')).toBe(true);
      expect(thinking.classList.contains('govuk-!-display-none')).toBe(true);
      expect(dontKnow.classList.contains('govuk-!-display-none')).toBe(false);
      expect(submitSpy).not.toHaveBeenCalled();
    });
  });
});

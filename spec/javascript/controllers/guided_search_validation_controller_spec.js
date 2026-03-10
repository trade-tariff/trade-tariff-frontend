import {Application} from '@hotwired/stimulus';
import GuidedSearchValidationController from '../../../app/javascript/controllers/guided_search_validation_controller';

function buildHTML({hiddenFieldValue = 'true', textareaValue = '', serverErrors = false} = {}) {
  const errorSummary = serverErrors ? `
    <div class="govuk-error-summary" data-module="govuk-error-summary">
      <div role="alert">
        <h2 class="govuk-error-summary__title">There is a problem</h2>
        <div class="govuk-error-summary__body">
          <ul class="govuk-list govuk-error-summary__list">
            <li><a href="#guided_q">Enter a search term</a></li>
          </ul>
        </div>
      </div>
    </div>` : '';

  const errorClass = serverErrors ? ' govuk-form-group--error' : '';
  const textareaErrorClass = serverErrors ? ' govuk-textarea--error' : '';
  const inlineError = serverErrors ? `
    <p class="govuk-error-message" id="guided-q-error">
      <span class="govuk-visually-hidden">Error:</span> Enter a search term
    </p>` : '';
  const ariaDescribedBy = serverErrors ? 'guided-q-hint guided-q-error' : 'guided-q-hint';

  return `
    <form data-controller="guided-search-validation"
          data-action="submit->guided-search-validation#validateAndSubmit"
          id="new_search">
      <div data-guided-search-validation-target="formContent">
        ${errorSummary}
        <div class="govuk-form-group${errorClass}" data-guided-search-validation-target="formGroup">
          <label class="govuk-label" for="guided_q">Describe the products you are trading</label>
          <div class="govuk-hint" id="guided-q-hint">For example, 55" 4K Ultra HD OLED Smart TV</div>
          ${inlineError}
          <textarea class="govuk-textarea${textareaErrorClass}" id="guided_q" name="q" rows="5"
                    aria-describedby="${ariaDescribedBy}"
                    data-guided-search-validation-target="textarea">${textareaValue}</textarea>
        </div>
        <input type="hidden" name="interactive_search" value="${hiddenFieldValue}"
               data-guided-search-validation-target="hiddenField">
        <button type="submit">Search for a commodity</button>
      </div>
      <div data-guided-search-validation-target="thinking" class="govuk-!-display-none">
        <p class="govuk-body-l">Collecting information...</p>
      </div>
    </form>
  `;
}

describe('GuidedSearchValidationController', () => {
  let application;

  async function setup(options) {
    document.body.innerHTML = buildHTML(options);
    application = Application.start();
    application.register('guided-search-validation', GuidedSearchValidationController);
    // Wait for Stimulus MutationObserver to connect the controller
    await new Promise((resolve) => setTimeout(resolve, 0));
  }

  function submitForm() {
    const form = document.querySelector('#new_search');
    const event = new Event('submit', {bubbles: true, cancelable: true});
    form.dispatchEvent(event);
    return form;
  }

  afterEach(() => {
    if (application) application.stop();
  });

  describe('keyword search', () => {
    it('bypasses validation entirely', async () => {
      await setup({hiddenFieldValue: 'false', textareaValue: ''});
      submitForm();

      expect(document.querySelector('.govuk-error-summary')).toBeNull();
    });
  });

  describe('guided search validation', () => {
    it('shows error when input is blank', async () => {
      await setup({textareaValue: ''});
      submitForm();

      const summary = document.querySelector('.govuk-error-summary');
      expect(summary).not.toBeNull();
      expect(summary.textContent).toContain('Enter a search term');

      const inline = document.querySelector('#guided-q-error');
      expect(inline).not.toBeNull();
      expect(inline.textContent).toContain('Enter a search term');
    });

    it('shows error when input is only whitespace', async () => {
      await setup({textareaValue: '   '});
      submitForm();

      expect(document.querySelector('.govuk-error-summary').textContent).toContain('Enter a search term');
    });

    it('shows error when input is 1 character', async () => {
      await setup({textareaValue: 'a'});
      submitForm();

      expect(document.querySelector('.govuk-error-summary').textContent).toContain('Search term must be at least 2 characters');
    });

    it('shows error when input exceeds 100 characters', async () => {
      await setup({textareaValue: 'a'.repeat(101)});
      submitForm();

      expect(document.querySelector('.govuk-error-summary').textContent).toContain('Search term must be 100 characters or fewer');
    });

    it('accepts exactly 2 characters', async () => {
      await setup({textareaValue: 'ab'});
      const form = submitForm();

      expect(document.querySelector('.govuk-error-summary')).toBeNull();
      expect(form.querySelector('[data-guided-search-validation-target="formContent"]').classList.contains('govuk-!-display-none')).toBe(true);
    });

    it('accepts exactly 100 characters', async () => {
      await setup({textareaValue: 'a'.repeat(100)});
      submitForm();

      expect(document.querySelector('.govuk-error-summary')).toBeNull();
    });
  });

  describe('error display', () => {
    it('creates GOV.UK error summary structure', async () => {
      await setup({textareaValue: ''});
      submitForm();

      const summary = document.querySelector('.govuk-error-summary');
      expect(summary.getAttribute('data-module')).toBe('govuk-error-summary');
      expect(summary.querySelector('[role="alert"]')).not.toBeNull();
      expect(summary.querySelector('.govuk-error-summary__title').textContent).toContain('There is a problem');
      expect(summary.querySelector('.govuk-error-summary__list a').getAttribute('href')).toBe('#guided_q');
    });

    it('adds error classes to form group and textarea', async () => {
      await setup({textareaValue: ''});
      submitForm();

      const formGroup = document.querySelector('[data-guided-search-validation-target="formGroup"]');
      const textarea = document.querySelector('#guided_q');

      expect(formGroup.classList.contains('govuk-form-group--error')).toBe(true);
      expect(textarea.classList.contains('govuk-textarea--error')).toBe(true);
    });

    it('places inline error before textarea', async () => {
      await setup({textareaValue: ''});
      submitForm();

      const textarea = document.querySelector('#guided_q');
      const inlineError = textarea.previousElementSibling;

      expect(inlineError.id).toBe('guided-q-error');
      expect(inlineError.classList.contains('govuk-error-message')).toBe(true);
      expect(inlineError.querySelector('.govuk-visually-hidden').textContent).toBe('Error:');
    });

    it('updates aria-describedby on textarea', async () => {
      await setup({textareaValue: ''});
      submitForm();

      const textarea = document.querySelector('#guided_q');
      expect(textarea.getAttribute('aria-describedby')).toBe('guided-q-hint guided-q-error');
    });
  });

  describe('error clearing', () => {
    it('clears errors on resubmit before re-validating', async () => {
      await setup({textareaValue: ''});
      submitForm();

      expect(document.querySelectorAll('.govuk-error-summary').length).toBe(1);

      // Submit again with a different value
      document.querySelector('#guided_q').value = 'x';
      submitForm();

      // Should only have one error summary (the new one)
      expect(document.querySelectorAll('.govuk-error-summary').length).toBe(1);
      expect(document.querySelector('.govuk-error-summary').textContent).toContain('at least 2 characters');
    });

    it('clears server-rendered errors on resubmit', async () => {
      await setup({serverErrors: true, textareaValue: 'valid input'});

      // Server errors should be present initially
      expect(document.querySelector('.govuk-error-summary')).not.toBeNull();
      expect(document.querySelector('#guided-q-error')).not.toBeNull();

      submitForm();

      // Server errors should be cleared, form should submit (no new errors)
      expect(document.querySelector('.govuk-error-summary')).toBeNull();
      expect(document.querySelector('#guided-q-error')).toBeNull();
    });

    it('resets form group and textarea classes on resubmit', async () => {
      await setup({textareaValue: ''});
      submitForm();

      const formGroup = document.querySelector('[data-guided-search-validation-target="formGroup"]');
      const textarea = document.querySelector('#guided_q');

      expect(formGroup.classList.contains('govuk-form-group--error')).toBe(true);

      textarea.value = 'valid search term';
      submitForm();

      expect(formGroup.classList.contains('govuk-form-group--error')).toBe(false);
      expect(textarea.classList.contains('govuk-textarea--error')).toBe(false);
      expect(textarea.getAttribute('aria-describedby')).toBe('guided-q-hint');
    });
  });

  describe('throbber', () => {
    it('hides form content and shows thinking on valid submit', async () => {
      await setup({textareaValue: 'televisions'});
      submitForm();

      const formContent = document.querySelector('[data-guided-search-validation-target="formContent"]');
      const thinking = document.querySelector('[data-guided-search-validation-target="thinking"]');

      expect(formContent.classList.contains('govuk-!-display-none')).toBe(true);
      expect(thinking.classList.contains('govuk-!-display-none')).toBe(false);
    });

    it('does not show throbber when validation fails', async () => {
      await setup({textareaValue: ''});
      submitForm();

      const formContent = document.querySelector('[data-guided-search-validation-target="formContent"]');
      const thinking = document.querySelector('[data-guided-search-validation-target="thinking"]');

      expect(formContent.classList.contains('govuk-!-display-none')).toBe(false);
      expect(thinking.classList.contains('govuk-!-display-none')).toBe(true);
    });
  });
});

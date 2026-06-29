import {Application} from '@hotwired/stimulus';
import GuidedSearchValidationController from '../../../app/javascript/controllers/guided_search_validation_controller';

function buildHTML({hiddenFieldValue = 'true', textareaValue = '', serverErrors = false} = {}) {
  const errorSummary = serverErrors ? `
    <div class="govuk-error-summary" data-module="govuk-error-summary">
      <div role="alert">
        <h2 class="govuk-error-summary__title">There is a problem</h2>
        <div class="govuk-error-summary__body">
          <ul class="govuk-list govuk-error-summary__list">
            <li><a href="#search-q-field-error">Enter a search term</a></li>
          </ul>
        </div>
      </div>
    </div>` : '';

  const errorClass = serverErrors ? ' govuk-form-group--error' : '';
  const textareaErrorClass = serverErrors ? ' govuk-textarea--error' : '';
  const inlineError = serverErrors ? `
    <p class="govuk-error-message" id="search-q-error">
      <span class="govuk-visually-hidden">Error:</span> Enter a search term
    </p>` : '';
  const ariaDescribedBy = serverErrors ? 'search-q-hint search-q-error' : 'search-q-hint';

  return `
    <main id="content">
    <div>
      <div data-guided-search-validation-page-content>
        <section id="find-commodity-intro">
          <h1>Look up commodity codes, import duties, taxes and controls</h1>
          <p>Search for a commodity</p>
        </section>
        <aside id="recent-news">Latest news</aside>
        <form data-controller="guided-search-validation"
              data-action="submit->guided-search-validation#validateAndSubmit"
              id="new_search"
              action="/search"
              method="post">
          <div data-guided-search-validation-target="formContent">
            ${errorSummary}
            <div class="govuk-form-group${errorClass}" data-guided-search-validation-target="formGroup">
              <label class="govuk-label" for="search-q-field">Describe the products you are trading</label>
              <div class="govuk-hint" id="search-q-hint">For example, 55" 4K Ultra HD OLED Smart TV</div>
              ${inlineError}
              <textarea class="govuk-textarea${textareaErrorClass}" id="search-q-field" name="search[q]" rows="5"
                        aria-describedby="${ariaDescribedBy}"
                        data-guided-search-validation-target="textarea">${textareaValue}</textarea>
            </div>
            <input type="hidden" name="interactive_search" value="${hiddenFieldValue}"
                   data-guided-search-validation-target="hiddenField">
            <button type="submit">Search for a commodity</button>
          </div>
        </form>
        <section id="other-ways">Other ways to search for a commodity</section>
      </div>
      <div data-guided-search-validation-loading-page class="govuk-!-display-none">
        <div role="status">
          <span>UK Integrated Online Tariff</span>
          <h1>Search for a commodity</h1>
          <p>Collecting information...</p>
        </div>
      </div>
    </div>
    </main>
  `;
}

describe('GuidedSearchValidationController', () => {
  let application;
  let submitSpy;
  let fetchSpy;
  let setTimeoutSpy;
  let scrollToSpy;

  async function setup(options) {
    document.body.innerHTML = buildHTML(options);
    application = Application.start();
    application.register('guided-search-validation', GuidedSearchValidationController);
    // Wait for Stimulus MutationObserver to connect the controller
    await Promise.resolve();
  }

  function submitForm() {
    const form = document.querySelector('#new_search');
    const event = new Event('submit', {bubbles: true, cancelable: true});
    form.dispatchEvent(event);
    return form;
  }

  beforeEach(() => {
    submitSpy = jest.spyOn(HTMLFormElement.prototype, 'submit').mockImplementation(() => {});
    setTimeoutSpy = jest.spyOn(window, 'setTimeout').mockImplementation(() => {});
    scrollToSpy = jest.spyOn(window, 'scrollTo').mockImplementation(() => {});
    global.fetch = jest.fn();
    fetchSpy = jest.spyOn(global, 'fetch').mockResolvedValue({
      redirected: false,
      text: () => Promise.resolve('<html><head><title>Results</title></head><body><main id="content"><h1>Search results</h1></main></body></html>'),
    });
  });

  afterEach(() => {
    if (application) application.stop();
    submitSpy.mockRestore();
    setTimeoutSpy.mockRestore();
    scrollToSpy.mockRestore();
    fetchSpy.mockRestore();
    delete global.fetch;
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

      const inline = document.querySelector('#search-q-field-inline-error');
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

    it('shows error when input exceeds 1000 characters', async () => {
      await setup({textareaValue: 'a'.repeat(1001)});
      submitForm();

      expect(document.querySelector('.govuk-error-summary').textContent).toContain('Search term must be 1000 characters or fewer');
    });

    it('accepts exactly 2 characters', async () => {
      await setup({textareaValue: 'ab'});
      const form = submitForm();

      expect(document.querySelector('.govuk-error-summary')).toBeNull();
      expect(form.querySelector('[data-guided-search-validation-target~="formContent"]').classList.contains('govuk-!-display-none')).toBe(true);
    });

    it('accepts exactly 1000 characters', async () => {
      await setup({textareaValue: 'a'.repeat(1000)});
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
      expect(summary.querySelector('.govuk-error-summary__list a').getAttribute('href')).toBe('#search-q-field');
    });

    it('adds error classes to form group and textarea', async () => {
      await setup({textareaValue: ''});
      submitForm();

      const formGroup = document.querySelector('[data-guided-search-validation-target="formGroup"]');
      const textarea = document.querySelector('#search-q-field');

      expect(formGroup.classList.contains('govuk-form-group--error')).toBe(true);
      expect(textarea.classList.contains('govuk-textarea--error')).toBe(true);
    });

    it('places inline error before textarea', async () => {
      await setup({textareaValue: ''});
      submitForm();

      const textarea = document.querySelector('#search-q-field');
      const inlineError = textarea.previousElementSibling;

      expect(inlineError.id).toBe('search-q-field-inline-error');
      expect(inlineError.classList.contains('govuk-error-message')).toBe(true);
      expect(inlineError.querySelector('.govuk-visually-hidden').textContent).toBe('Error:');
    });

    it('updates aria-describedby on textarea', async () => {
      await setup({textareaValue: ''});
      submitForm();

      const textarea = document.querySelector('#search-q-field');
      expect(textarea.getAttribute('aria-describedby')).toBe('search-q-hint search-q-field-inline-error');
    });
  });

  describe('error clearing', () => {
    it('clears errors on resubmit before re-validating', async () => {
      await setup({textareaValue: ''});
      submitForm();

      expect(document.querySelectorAll('.govuk-error-summary').length).toBe(1);

      // Submit again with a different value
      document.querySelector('#search-q-field').value = 'x';
      submitForm();

      // Should only have one error summary (the new one)
      expect(document.querySelectorAll('.govuk-error-summary').length).toBe(1);
      expect(document.querySelector('.govuk-error-summary').textContent).toContain('at least 2 characters');
    });

    it('clears server-rendered errors on resubmit', async () => {
      await setup({serverErrors: true, textareaValue: 'valid input'});

      // Server errors should be present initially
      expect(document.querySelector('.govuk-error-summary')).not.toBeNull();
      expect(document.querySelector('.govuk-error-message')).not.toBeNull();

      submitForm();

      // Server errors should be cleared, form should submit (no new errors)
      expect(document.querySelector('.govuk-error-summary')).toBeNull();
      expect(document.querySelector('.govuk-error-message')).toBeNull();
    });

    it('resets form group and textarea classes on resubmit', async () => {
      await setup({textareaValue: ''});
      submitForm();

      const formGroup = document.querySelector('[data-guided-search-validation-target="formGroup"]');
      const textarea = document.querySelector('#search-q-field');

      expect(formGroup.classList.contains('govuk-form-group--error')).toBe(true);

      textarea.value = 'valid search term';
      submitForm();

      expect(formGroup.classList.contains('govuk-form-group--error')).toBe(false);
      expect(textarea.classList.contains('govuk-textarea--error')).toBe(false);
      expect(textarea.getAttribute('aria-describedby')).toBe('search-q-hint');
    });
  });

  describe('throbber', () => {
    it('hides form content and shows thinking on valid submit', async () => {
      await setup({textareaValue: 'televisions'});
      submitForm();

      const formContent = document.querySelector('[data-guided-search-validation-target~="formContent"]');
      const loadingPage = document.querySelector('[data-guided-search-validation-loading-page]');

      expect(formContent.classList.contains('govuk-!-display-none')).toBe(true);
      expect(loadingPage.classList.contains('govuk-!-display-none')).toBe(false);
      expect(loadingPage.textContent).toContain('Search for a commodity');
      expect(loadingPage.textContent).toContain('Collecting information...');
      expect(loadingPage.textContent).not.toContain('Searching for commodity codes');
    });

    it('hides the rest of the find commodity page on valid submit', async () => {
      await setup({textareaValue: 'televisions'});
      submitForm();

      expect(document.querySelector('[data-guided-search-validation-page-content]').classList.contains('govuk-!-display-none')).toBe(true);
    });

    it('scrolls to the top before showing the loading page', async () => {
      await setup({textareaValue: 'televisions'});
      submitForm();

      expect(scrollToSpy).toHaveBeenCalledWith({top: 0, left: 0});
      expect(scrollToSpy.mock.invocationCallOrder[0]).toBeLessThan(
        setTimeoutSpy.mock.invocationCallOrder[0],
      );
    });

    it('does not show throbber when validation fails', async () => {
      await setup({textareaValue: ''});
      submitForm();

      const formContent = document.querySelector('[data-guided-search-validation-target~="formContent"]');
      const loadingPage = document.querySelector('[data-guided-search-validation-loading-page]');

      expect(formContent.classList.contains('govuk-!-display-none')).toBe(false);
      expect(loadingPage.classList.contains('govuk-!-display-none')).toBe(true);
    });

    it('submits the form after rendering the loading page', async () => {
      await setup({textareaValue: 'televisions'});
      const form = submitForm();

      window.setTimeout.mock.calls[0][0]();

      expect(submitSpy).toHaveBeenCalledWith();
      expect(form.querySelector('[data-guided-search-validation-target~="formContent"]').classList.contains('govuk-!-display-none')).toBe(true);
    });

    it('does not submit the form before the loading page renders', async () => {
      await setup({textareaValue: 'televisions'});
      submitForm();

      expect(submitSpy).not.toHaveBeenCalled();
      expect(document.querySelector('[data-guided-search-validation-loading-page]').classList.contains('govuk-!-display-none')).toBe(false);
    });
  });
});

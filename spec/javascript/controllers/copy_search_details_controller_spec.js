import {Application} from '@hotwired/stimulus';
import CopySearchDetailsController from '../../../app/javascript/controllers/copy_search_details_controller';

describe('CopySearchDetailsController', () => {
  let application;
  let originalExecCommand;

  beforeEach(() => {
    originalExecCommand = document.execCommand;
    document.execCommand = undefined;

    document.body.innerHTML = `
      <details class="govuk-details" data-controller="copy-search-details">
        <summary class="govuk-details__summary">
          <span class="govuk-details__summary-text">View search details</span>
        </summary>
        <div class="govuk-details__text">
          <p>Search term: citrus jam</p>
          <p>What type of fruit? Citrus</p>
          <button data-action="copy-search-details#copy"
                  data-copy-search-details-target="button">
            Copy search details
          </button>
        </div>
      </details>
    `;

    application = Application.start();
    application.register('copy-search-details', CopySearchDetailsController);
  });

  afterEach(() => {
    application.stop();
    document.execCommand = originalExecCommand;
  });

  describe('#copy', () => {
    it('copies text to clipboard and shows confirmation', async () => {
      const writeText = jest.fn().mockResolvedValue(undefined);
      Object.assign(navigator, {clipboard: {writeText}});

      jest.useFakeTimers();

      const button = document.querySelector('button');
      button.click();

      await Promise.resolve();

      expect(writeText).toHaveBeenCalledWith(
        expect.stringContaining('citrus jam'),
      );
      expect(button.textContent).toBe('Copied');

      jest.advanceTimersByTime(2000);
      expect(button.textContent).toBe('Copy search details');

      jest.useRealTimers();
    });

    it('copies text from an explicit content target', async () => {
      document.body.innerHTML = `
        <div data-controller="copy-search-details">
          <div data-copy-search-details-target="content">
            <p>Initial search term: citrus jam</p>
            <p>What type of fruit? Citrus</p>
          </div>
          <button data-action="copy-search-details#copy"
                  data-copy-search-details-target="button">
            Copy results to clipboard
          </button>
        </div>
      `;

      const writeText = jest.fn().mockResolvedValue(undefined);
      Object.assign(navigator, {clipboard: {writeText}});

      const button = document.querySelector('button');
      await Promise.resolve();
      button.click();

      await Promise.resolve();

      expect(writeText).toHaveBeenCalledWith(
        'Initial search term: citrus jam\nWhat type of fruit? Citrus',
      );
      expect(button.textContent).toBe('Copied');
    });

    it('uses the synchronous clipboard fallback when available', async () => {
      Object.assign(navigator, {clipboard: undefined});
      document.execCommand = jest.fn().mockReturnValue(true);

      const button = document.querySelector('button');
      button.click();

      await Promise.resolve();

      expect(document.execCommand).toHaveBeenCalledWith('copy');
      expect(button.textContent).toBe('Copied');
    });

    it('prefers the Clipboard API over the legacy fallback', async () => {
      const writeText = jest.fn().mockResolvedValue(undefined);
      Object.assign(navigator, {clipboard: {writeText}});
      document.execCommand = jest.fn().mockReturnValue(true);

      const button = document.querySelector('button');
      button.click();

      await Promise.resolve();

      expect(writeText).toHaveBeenCalledWith(
        expect.stringContaining('citrus jam'),
      );
      expect(document.execCommand).not.toHaveBeenCalled();
      expect(button.textContent).toBe('Copied');
    });
  });
});

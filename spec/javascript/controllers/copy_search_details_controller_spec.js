import {Application} from '@hotwired/stimulus';
import CopySearchDetailsController from '../../../app/javascript/controllers/copy_search_details_controller';

describe('CopySearchDetailsController', () => {
  let application;

  beforeEach(() => {
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
  });
});

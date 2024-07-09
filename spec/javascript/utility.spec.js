import Utility from 'utility';

describe('Utility.countrySelectorOnConfirm', () => {
  let selectElement; let form; let anchorInput; let originalLocation;

  beforeEach(() => {
    // Save the original location so we can restore it after the test
    originalLocation = window.location;

    // Mock the window location
    delete window.location;
    window.location = {
      href: '',
      hash: '#origin',
    };

    // Create a mock select element and other necessary DOM elements
    document.body.innerHTML = `
      <div class="commodity-header" data-comm-code="1234"></div>
      <form>
        <div class="govuk-fieldset">
          <input value="uk" autocomplete="off" type="hidden" name="trading_partner[service]" id="trading_partner_service" />
          <input autocomplete="off" type="hidden" name="trading_partner[anchor]" id="trading_partner_anchor" />
          <select>
            <option value="AF">(AF)</option>
            <option value="ZW">(ZW)</option>
          </select>
        </div>
      </form>
    `;

    selectElement = document.querySelector('select');
    form = selectElement.closest('form');
    anchorInput = selectElement.closest('.govuk-fieldset').querySelector('input[name$="[anchor]"]');
  });

  afterEach(() => {
    // Restore the original location
    window.location = originalLocation;
  });

  it('navigates to the URL for "All countries"', () => {
    const confirmed = 'All countries';

    Utility.countrySelectorOnConfirm(confirmed, selectElement);

    expect(window.location.href).toBe('/commodities/1234#origin');
  });

  it('sets the select element value and submits the form for a specific country', () => {
    // Check if form.submit is called
    form.submit = jest.fn();

    const confirmed = 'Afghanistan (AF)';

    Utility.countrySelectorOnConfirm(confirmed, selectElement);

    expect(selectElement.value).toBe('AF');
    expect(anchorInput.value).toBe('origin');
    expect(form.submit).toHaveBeenCalled();
  });

  it('navigates to the URL with service "xi" for "All countries"', () => {
    // Set the service to 'xi'
    document.getElementById('trading_partner_service').value = 'xi';

    const confirmed = 'All countries';

    Utility.countrySelectorOnConfirm(confirmed, selectElement);

    expect(window.location.href).toBe(`${window.location.origin}/xi/commodities/1234#origin`);
  });
});

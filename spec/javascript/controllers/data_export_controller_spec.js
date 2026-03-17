import { Application } from '@hotwired/stimulus';
import DataExportController from '../../../app/javascript/controllers/data_export_controller';

describe('DataExportController', () => {
  let application;
  let element;
  let statusTarget;
  let spinnerTarget;
  let spinnerStatusTarget;
  let downloadTarget;
  let failedTarget;

  const flushPromises = async () => {
    await Promise.resolve();
    await Promise.resolve();
  };

  const mountDom = () => {
    document.body.innerHTML = `
      <div
        id="data-export-root"
        data-controller="data-export"
        data-data-export-status-url-value="/subscriptions/mycommodities/get_data_export_status?export_id=5"
        data-data-export-poll-interval-value="2000"
      >
        <div data-data-export-target="dataExportStatus">Status: Queued</div>
        <div data-data-export-target="spinner">
          <span data-data-export-target="spinnerStatus">Queued...</span>
        </div>
        <div data-data-export-target="downloadContainer" hidden></div>
        <div data-data-export-target="failedContainer" hidden></div>
      </div>
    `;

    element = document.querySelector('#data-export-root');
    statusTarget = element.querySelector('[data-data-export-target="dataExportStatus"]');
    spinnerTarget = element.querySelector('[data-data-export-target="spinner"]');
    spinnerStatusTarget = element.querySelector('[data-data-export-target="spinnerStatus"]');
    downloadTarget = element.querySelector('[data-data-export-target="downloadContainer"]');
    failedTarget = element.querySelector('[data-data-export-target="failedContainer"]');
  };

  const startControllerWithResponse = (response) => {
    jest.useFakeTimers();
    global.fetch = jest.fn().mockResolvedValue(response);
    mountDom();

    application = Application.start();
    application.register('data-export', DataExportController);
  };

  afterEach(() => {
    if (application) application.stop();
    jest.clearAllTimers();
    jest.useRealTimers();
    jest.restoreAllMocks();
  });

  it('polls on connect and schedules interval polling', async () => {
    startControllerWithResponse({
      ok: true,
      json: async () => ({ status: 'queued' }),
    });

    await flushPromises();

    expect(fetch).toHaveBeenCalledWith(
      '/subscriptions/mycommodities/get_data_export_status?export_id=5',
      {
        headers: { Accept: 'application/json' },
        credentials: 'same-origin',
      },
    );

    fetch.mockClear();

    jest.advanceTimersByTime(2000);
    await flushPromises();

    expect(fetch).toHaveBeenCalledTimes(1);
  });

  it('shows completed wording and download when status is completed', async () => {
    startControllerWithResponse({
      ok: true,
      json: async () => ({ status: 'completed' }),
    });

    const clearIntervalSpy = jest.spyOn(global, 'clearInterval');

    await flushPromises();

    expect(statusTarget.textContent).toBe('Status: Completed');
    expect(spinnerStatusTarget.textContent).toBe('Completed...');
    expect(spinnerTarget.hidden).toBe(true);
    expect(downloadTarget.hidden).toBe(false);
    expect(failedTarget.hidden).toBe(true);
    expect(clearIntervalSpy).toHaveBeenCalled();
  });

  it('shows queued wording and keeps spinner visible when status is queued', async () => {
    startControllerWithResponse({
      ok: true,
      json: async () => ({ status: 'queued' }),
    });

    await flushPromises();

    expect(statusTarget.textContent).toBe('Status: Queued');
    expect(spinnerStatusTarget.textContent).toBe('Queued...');
    expect(spinnerTarget.hidden).toBe(false);
    expect(downloadTarget.hidden).toBe(true);
    expect(failedTarget.hidden).toBe(true);
  });

  it('shows processing wording and keeps spinner visible when status is processing', async () => {
    startControllerWithResponse({
      ok: true,
      json: async () => ({ status: 'processing' }),
    });

    await flushPromises();

    expect(statusTarget.textContent).toBe('Status: Generating file');
    expect(spinnerStatusTarget.textContent).toBe('Generating file...');
    expect(spinnerTarget.hidden).toBe(false);
    expect(downloadTarget.hidden).toBe(true);
    expect(failedTarget.hidden).toBe(true);
  });

  it('shows failed wording and failed container when status is failed', async () => {
    startControllerWithResponse({
      ok: true,
      json: async () => ({ status: 'failed' }),
    });

    const clearIntervalSpy = jest.spyOn(global, 'clearInterval');

    await flushPromises();

    expect(statusTarget.textContent).toBe('Status: Failed');
    expect(spinnerStatusTarget.textContent).toBe('Failed...');
    expect(spinnerTarget.hidden).toBe(true);
    expect(downloadTarget.hidden).toBe(true);
    expect(failedTarget.hidden).toBe(false);
    expect(clearIntervalSpy).toHaveBeenCalled();
  });

  it('shows not found wording for 404 responses', async () => {
    startControllerWithResponse({
      ok: false,
      status: 404,
    });

    const clearIntervalSpy = jest.spyOn(global, 'clearInterval');

    await flushPromises();

    expect(statusTarget.textContent).toBe('Status: Not found');
    expect(spinnerStatusTarget.textContent).toBe('Not found...');
    expect(spinnerTarget.hidden).toBe(true);
    expect(downloadTarget.hidden).toBe(true);
    expect(failedTarget.hidden).toBe(false);
    expect(clearIntervalSpy).toHaveBeenCalled();
  });

  it('shows checking status wording for non-404 errors', async () => {
    startControllerWithResponse({
      ok: false,
      status: 500,
    });

    await flushPromises();

    expect(statusTarget.textContent).toBe('Status: Checking status');
    expect(spinnerStatusTarget.textContent).toBe('Checking status...');
  });

  it('shows checking status wording when fetch throws', async () => {
    jest.useFakeTimers();
    global.fetch = jest.fn().mockRejectedValue(new Error('network error'));
    mountDom();

    application = Application.start();
    application.register('data-export', DataExportController);

    await flushPromises();

    expect(statusTarget.textContent).toBe('Status: Checking status');
    expect(spinnerStatusTarget.textContent).toBe('Checking status...');
  });
});

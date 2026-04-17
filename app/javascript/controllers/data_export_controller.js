import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['dataExportStatus', 'spinner', 'downloadContainer', 'spinnerStatus', 'failedContainer'];

  static values = {
    statusUrl: String,
    pollInterval: { type: Number, default: 2000 },
  };

  connect() {
    this.poll();
    this.timer = setInterval(() => this.poll(), this.pollIntervalValue);
  }

  disconnect() {
    if (this.timer) clearInterval(this.timer);
  }

  updateStatusText(status) {
    const labels = {
      queued: 'Queued',
      processing: 'Generating file',
      completed: 'Completed',
      failed: 'Failed',
      not_found: 'Not found',
      unknown: 'Checking status',
    };

    const label = labels[status] || status;

    this.dataExportStatusTarget.textContent = `Status: ${label}`;

    if (this.hasSpinnerStatusTarget) {
      this.spinnerStatusTarget.textContent = `${label}...`;
    }
  }

  async poll() {
    try {
      const response = await fetch(this.statusUrlValue, {
        headers: { Accept: 'application/json' },
        credentials: 'same-origin',
      });

      if (!response.ok) {
        const fallbackStatus = response.status === 404 ? 'not_found' : 'unknown';
        this.updateStatusText(fallbackStatus);

        if (fallbackStatus === 'not_found') {
          this.spinnerTarget.hidden = true;
          this.downloadContainerTarget.hidden = true;
          this.failedContainerTarget.hidden = false;
          clearInterval(this.timer);
        }

        return;
      }

      const data = await response.json();
      const status = data.status || 'unknown';
      this.updateStatusText(status);

      if (status === 'completed') {
        this.spinnerTarget.hidden = true;
        this.downloadContainerTarget.hidden = false;
        this.failedContainerTarget.hidden = true;
        clearInterval(this.timer);
        return;
      }

      if (status === 'queued' || status === 'processing') {
        this.spinnerTarget.hidden = false;
        this.downloadContainerTarget.hidden = true;
        this.failedContainerTarget.hidden = true;
        return;
      }

      if (status === 'failed' || status === 'not_found') {
        this.spinnerTarget.hidden = true;
        this.downloadContainerTarget.hidden = true;
        this.failedContainerTarget.hidden = false;
        clearInterval(this.timer);
      }
    } catch (_error) {
      this.updateStatusText('unknown');
    }
  }
}

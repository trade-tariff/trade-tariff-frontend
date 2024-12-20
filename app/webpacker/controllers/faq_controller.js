import {Controller} from '@hotwired/stimulus';

export default class extends Controller {
  connect() {
  }

  saveFeedback(event) {
    let category_id = event.currentTarget.value.split('|')[0].split('_')[1].trim();
    let question_id = event.currentTarget.value.split('|')[1].split('_')[1].trim();
    let useful = event.currentTarget.value.split('|')[2];
    if (!this.feedbackExistsInSession(category_id, question_id)) {
          if(this.sendFeedbackToBackend(category_id, question_id, useful)){
            this.saveFeedbackToCookie(category_id, question_id);
          }
    }
  }

  saveFeedbackToCookie(category_id, question_id) {
    document.cookie = `${category_id}${question_id}=y`;
  }

  feedbackExistsInSession(category_id, question_id) {
    let cookies = document.cookie.split(';');
    for (let i = 0; i < cookies.length; i++) {
        let cookie = cookies[i].trim().split('=');
        if (cookie[0] === `${category_id}${question_id}`) {
            return true;
        }
    }
    return false;
  }

  async sendFeedbackToBackend(category_id, question_id, useful) {
    const faqFeedbackPath = document.querySelector('.path_info').dataset.faqSendFeedbackPath;
    const fetchURL = new URL(window.location.href);
    fetchURL.pathname = faqFeedbackPath;
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    const payload = {
      faq_feedback: {
        category_id: category_id,
        question_id: question_id,
        useful: useful,
      }
    };

    try {
      const response = await fetch(fetchURL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
        },
        body: JSON.stringify(payload),
      });
    } catch (error) {
      console.error('Error sending feedback:', error);
    }
  }
}

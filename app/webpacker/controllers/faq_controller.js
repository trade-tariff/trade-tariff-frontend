import {Controller} from '@hotwired/stimulus';

export default class extends Controller {
  connect() {
  }

  saveFeedback(event) {
    const categoryId = event.currentTarget.value.split('|')[0].split('_')[1].trim();
    const questionId = event.currentTarget.value.split('|')[1].split('_')[1].trim();
    const useful = event.currentTarget.value.split('|')[2];
    if (!this.feedbackExistsInSession(categoryId, questionId)) {
      if (this.sendFeedbackToBackend(categoryId, questionId, useful)) {
        this.saveFeedbackToCookie(categoryId, questionId);
      }
    }
  }

  saveFeedbackToCookie(categoryId, questionId) {
    document.cookie = `${categoryId}${questionId}=y`;
  }

  feedbackExistsInSession(categoryId, questionId) {
    const cookies = document.cookie.split(';');
    for (let i = 0; i < cookies.length; i++) {
      const cookie = cookies[i].trim().split('=');
      if (cookie[0] === `${categoryId}${questionId}`) {
        return true;
      }
    }
    return false;
  }

  async sendFeedbackToBackend(categoryId, questionId, useful) {
    const faqFeedbackPath = document.querySelector('.path_info').dataset.faqSendFeedbackPath;
    const fetchURL = new URL(window.location.href);
    fetchURL.pathname = faqFeedbackPath;
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    const payload = {
      faq_feedback: {
        category_id: categoryId,
        question_id: questionId,
        useful: useful,
      },
    };

    try {
      await fetch(fetchURL, {
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

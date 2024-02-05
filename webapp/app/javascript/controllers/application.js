import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }

addEventListener("turbo:before-stream-render", ((event) => {
  const fallbackToDefaultActions = event.detail.render;
  document.getElementById('question-input').value = '';
  document.getElementById('question-input').disabled = false;
}));

addEventListener("turbo:submit-start", ((event) => {
  document.getElementById('question-input').disabled = true;
}));

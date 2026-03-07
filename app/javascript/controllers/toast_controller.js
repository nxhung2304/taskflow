import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    autoDismiss: { type: Boolean, default: true },
    duration: { type: Number, default: 3000 }
  }

  connect() {
    if (this.autoDismissValue) {
      this.scheduleRemoval()
    }
  }

  scheduleRemoval() {
    setTimeout(() => {
      this.dismiss()
    }, this.durationValue)
  }

  dismiss() {
    // Fade out animation
    this.element.classList.add('toast-exit')

    // Remove element after animation
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }

  close(event) {
    event.preventDefault()
    this.dismiss()
  }
}

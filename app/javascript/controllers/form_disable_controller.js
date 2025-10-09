import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "field", "submit" ]

  connect() {
    if (document.querySelector("[data-controller='timer']")) {
      this.disableAll()
    }
  }

  submit(event) {
    // Auto-submit the form when the field changes
    this.element.requestSubmit()
  }

  disableAll() {
    this.fieldTargets.forEach(field => field.disabled = true)
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = true
    }
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]

  connect() {
    // Start collapsed
    this.contentTarget.style.display = "none"
  }

  toggle() {
    if (this.contentTarget.style.display === "none") {
      this.contentTarget.style.display = ""
      if (this.hasIconTarget) {
        this.iconTarget.classList.remove("bi-chevron-right")
        this.iconTarget.classList.add("bi-chevron-down")
      }
    } else {
      this.contentTarget.style.display = "none"
      if (this.hasIconTarget) {
        this.iconTarget.classList.remove("bi-chevron-down")
        this.iconTarget.classList.add("bi-chevron-right")
      }
    }
  }
}

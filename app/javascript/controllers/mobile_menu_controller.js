import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    this.menuTarget.classList.toggle("active")
  }

  // Close menu when clicking outside
  connect() {
    this.boundHandleClickOutside = this.handleClickOutside.bind(this)
    document.addEventListener("click", this.boundHandleClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.boundHandleClickOutside)
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target) && this.menuTarget.classList.contains("active")) {
      this.menuTarget.classList.remove("active")
    }
  }
}

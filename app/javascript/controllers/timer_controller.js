import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { startTime: String }
  static targets = [ "elapsed" ]

  connect() {
    this.timer = setInterval(() => {
      this.updateElapsedTime()
    }, 1000)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  updateElapsedTime() {
    const startTime = new Date(this.startTimeValue)
    const now = new Date()
    const elapsedSeconds = Math.round((now - startTime) / 1000)
    this.elapsedTarget.textContent = this.formatDuration(elapsedSeconds)
  }

  formatDuration(seconds) {
    const h = Math.floor(seconds / 3600).toString().padStart(2, '0');
    const m = Math.floor((seconds % 3600) / 60).toString().padStart(2, '0');
    const s = (seconds % 60).toString().padStart(2, '0');
    return `${h}:${m}:${s}`;
  }
}

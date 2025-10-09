import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["clientSelect", "clientNew", "projectSelect", "projectNew", "taskSelect", "taskNew"]

  toggleClient(event) {
    event.preventDefault()
    const isCreatingNew = this.clientNewTarget.classList.toggle("hidden")
    this.clientSelectTarget.classList.toggle("hidden")

    if (!isCreatingNew) {
      // Clear the select when showing new client form
      this.clientSelectTarget.querySelector("select").value = ""
    }
  }

  toggleProject(event) {
    event.preventDefault()
    const isCreatingNew = this.projectNewTarget.classList.toggle("hidden")
    this.projectSelectTarget.classList.toggle("hidden")

    if (!isCreatingNew) {
      // Clear the select when showing new project form
      this.projectSelectTarget.querySelector("select").value = ""
    }
  }

  toggleTask(event) {
    event.preventDefault()
    const isCreatingNew = this.taskNewTarget.classList.toggle("hidden")
    this.taskSelectTarget.classList.toggle("hidden")

    if (!isCreatingNew) {
      // Clear the select when showing new task form
      this.taskSelectTarget.querySelector("select").value = ""
    }
  }
}
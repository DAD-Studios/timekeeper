import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "client", "project" ]

  connect() {
    console.log("Project select controller connected")
    console.log("Has client target:", this.hasClientTarget)
    console.log("Has project target:", this.hasProjectTarget)

    // On page load, if a client is already selected, populate the projects
    if (this.hasClientTarget && this.clientTarget.value) {
      const selectedProjectId = this.projectTarget.value
      this.filterProjects().then(() => {
        // After projects are loaded, restore the selected project
        if (selectedProjectId) {
          this.projectTarget.value = selectedProjectId
        }
      })
    }
  }

  filterProjects() {
    console.log("filterProjects called")
    const clientId = this.clientTarget.value
    console.log("Client ID:", clientId)
    const projectSelect = this.projectTarget
    console.log("Project select element:", projectSelect)

    if (clientId) {
      console.log("Fetching projects for client:", clientId)
      return fetch(`/api/projects?client_id=${clientId}`)
        .then(response => {
          console.log("Response:", response)
          return response.json()
        })
        .then(projects => {
          console.log("Projects received:", projects)
          projectSelect.innerHTML = '<option value="">Select a Project</option>'
          projects.forEach(project => {
            const option = document.createElement('option')
            option.value = project.id
            option.textContent = project.name
            projectSelect.appendChild(option)
          })
          console.log("Projects added to select")
          // Trigger task filter to clear tasks when client changes
          const event = new Event('change', { bubbles: true })
          projectSelect.dispatchEvent(event)
        })
        .catch(error => {
          console.error("Error fetching projects:", error)
        })
    } else {
      projectSelect.innerHTML = '<option value="">Select a Project</option>'
      return Promise.resolve()
    }
  }
}

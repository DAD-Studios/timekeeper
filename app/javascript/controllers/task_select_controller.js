import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["client", "project", "taskDropdown"]

  connect() {
    this.allTasks = []
    this.loadTasks()
  }

  async loadTasks() {
    try {
      const response = await fetch('/api/tasks')
      this.allTasks = await response.json()
    } catch (error) {
      console.error('Error loading tasks:', error)
    }
  }

  filterTasks() {
    const clientId = this.clientTarget.value
    const projectId = this.projectTarget.value

    if (!clientId || !projectId) {
      this.taskDropdownTarget.innerHTML = '<option value="">Select an existing task</option>'
      return
    }

    const filteredTasks = this.allTasks.filter(task =>
      task.client_id == clientId && task.project_id == projectId
    )

    // Get unique task names
    const uniqueTasks = [...new Set(filteredTasks.map(task => task.task))]

    this.taskDropdownTarget.innerHTML = '<option value="">Select an existing task</option>' +
      uniqueTasks.map(task => `<option value="${task}">${task}</option>`).join('')
  }
}

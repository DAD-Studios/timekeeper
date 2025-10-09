import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["timeEntriesSection", "timeEntriesList", "manualLineItems", "emptyState"]

  connect() {
    this.lineItemIndex = 1000 // Start high to avoid conflicts with existing items
    this.setupExistingLineItems()
    this.updateEmptyState()
  }

  setupExistingLineItems() {
    // Setup amount calculation for existing line items
    const existingItems = this.manualLineItemsTarget.querySelectorAll('.line-item-row')
    existingItems.forEach(lineItem => {
      this.setupLineItemCalculation(lineItem)
    })
  }

  async loadTimeEntries(event) {
    const clientId = event.target.value

    if (!clientId) {
      this.timeEntriesSectionTarget.style.display = 'none'
      return
    }

    try {
      const response = await fetch(`/invoices/new?client_id=${clientId}`, {
        headers: {
          'Accept': 'application/json'
        }
      })

      if (!response.ok) throw new Error('Failed to load time entries')

      const data = await response.json()

      if (data.time_entries && data.time_entries.length > 0) {
        this.renderTimeEntries(data.time_entries)
        this.timeEntriesSectionTarget.style.display = 'block'
      } else {
        this.timeEntriesSectionTarget.style.display = 'none'
      }
    } catch (error) {
      console.error('Error loading time entries:', error)
    }
  }

  renderTimeEntries(timeEntries) {
    // Group by project
    const byProject = {}
    timeEntries.forEach(te => {
      const projectName = te.project_name || 'No Project'
      if (!byProject[projectName]) {
        byProject[projectName] = []
      }
      byProject[projectName].push(te)
    })

    let html = '<div style="max-height: 400px; overflow-y: auto; border: 1px solid #e1e8ed; border-radius: 4px;">'
    html += '<table style="margin: 0;">'
    html += '<thead style="position: sticky; top: 0; background: white; z-index: 10;">'
    html += '<tr><th style="width: 50px;"></th><th>Task</th><th>Date & Time</th><th>Hours</th><th>Rate</th><th>Amount</th></tr>'
    html += '</thead><tbody>'

    Object.keys(byProject).forEach(projectName => {
      const entries = byProject[projectName]
      const totalHours = entries.reduce((sum, te) => sum + parseFloat(te.duration_hours || 0), 0)
      const totalAmount = entries.reduce((sum, te) => sum + parseFloat(te.earnings || 0), 0)

      // Project header row
      html += `
        <tr style="background: #f5f7fa; font-weight: 600;">
          <td colspan="6" style="padding: 0.75rem 1rem;">
            <div style="display: flex; justify-content: space-between; align-items: center;">
              <span><i class="bi bi-folder"></i> ${this.escapeHtml(projectName)}</span>
              <span style="font-size: 14px; color: #5a6c7d;">${totalHours.toFixed(2)} hours • $${totalAmount.toFixed(2)}</span>
            </div>
          </td>
        </tr>
      `

      entries.forEach(te => {
        html += `
          <tr style="border-bottom: 1px solid #e1e8ed;">
            <td style="text-align: center;">
              <input type="checkbox"
                     data-time-entry-id="${te.id}"
                     data-description="${this.escapeHtml(te.task)}"
                     data-quantity="${te.duration_hours}"
                     data-rate="${te.rate}"
                     data-action="change->invoice-form#toggleTimeEntry"
                     style="cursor: pointer; width: 18px; height: 18px;">
            </td>
            <td><strong>${this.escapeHtml(te.task)}</strong></td>
            <td style="font-size: 14px; color: #5a6c7d;">${te.start_time} - ${te.end_time}</td>
            <td style="font-size: 14px;">${te.duration_hours} hrs</td>
            <td style="font-size: 14px;">$${te.rate}/hr</td>
            <td style="font-weight: 600; color: #5cb85c;">$${te.earnings}</td>
          </tr>
        `
      })
    })

    html += '</tbody></table></div>'
    this.timeEntriesListTarget.innerHTML = html
  }

  selectAll(event) {
    event.preventDefault()
    const checkboxes = this.timeEntriesListTarget.querySelectorAll('input[type="checkbox"]')
    const allChecked = Array.from(checkboxes).every(cb => cb.checked)

    checkboxes.forEach(checkbox => {
      if (allChecked) {
        checkbox.checked = false
        this.removeTimeEntryLineItem(checkbox.dataset.timeEntryId)
      } else if (!checkbox.checked) {
        checkbox.checked = true
        this.addTimeEntryLineItem(
          checkbox.dataset.timeEntryId,
          checkbox.dataset.description,
          parseFloat(checkbox.dataset.quantity),
          parseFloat(checkbox.dataset.rate)
        )
      }
    })

    // Update button text
    event.target.innerHTML = allChecked
      ? '<i class="bi bi-check-all"></i> Select All'
      : '<i class="bi bi-x-circle"></i> Deselect All'
  }

  toggleTimeEntry(event) {
    const checkbox = event.target
    const timeEntryId = checkbox.dataset.timeEntryId

    if (checkbox.checked) {
      this.addTimeEntryLineItem(
        timeEntryId,
        checkbox.dataset.description,
        parseFloat(checkbox.dataset.quantity),
        parseFloat(checkbox.dataset.rate)
      )
    } else {
      this.removeTimeEntryLineItem(timeEntryId)
    }
  }

  addTimeEntryLineItem(timeEntryId, description, quantity, rate) {
    const template = document.getElementById('line-item-template')
    const clone = template.content.cloneNode(true)
    const container = clone.querySelector('.line-item-row')

    container.dataset.timeEntryId = timeEntryId

    // Replace INDEX with actual index
    container.innerHTML = container.innerHTML.replace(/INDEX/g, this.lineItemIndex)

    // Set values
    container.querySelector('input[name*="[description]"]').value = description
    container.querySelector('input[name*="[quantity]"]').value = quantity
    container.querySelector('input[name*="[rate]"]').value = rate

    // Add hidden field for time_entry_id
    const hiddenField = document.createElement('input')
    hiddenField.type = 'hidden'
    hiddenField.name = `invoice[line_items_attributes][${this.lineItemIndex}][time_entry_id]`
    hiddenField.value = timeEntryId
    container.appendChild(hiddenField)

    this.manualLineItemsTarget.appendChild(container)
    this.setupLineItemCalculation(container)
    this.lineItemIndex++
    this.updateEmptyState()
  }

  removeTimeEntryLineItem(timeEntryId) {
    const lineItem = this.manualLineItemsTarget.querySelector(`[data-time-entry-id="${timeEntryId}"]`)
    if (lineItem) {
      lineItem.remove()
      this.updateEmptyState()
    }
  }

  addLineItem(event) {
    event.preventDefault()

    const template = document.getElementById('line-item-template')
    const clone = template.content.cloneNode(true)
    const container = clone.querySelector('.line-item-row')

    // Replace INDEX with actual index
    container.innerHTML = container.innerHTML.replace(/INDEX/g, this.lineItemIndex)

    this.manualLineItemsTarget.appendChild(container)
    this.setupLineItemCalculation(container)
    this.lineItemIndex++
    this.updateEmptyState()
  }

  setupLineItemCalculation(lineItem) {
    const quantityInput = lineItem.querySelector('.line-item-quantity, input[name*="[quantity]"]')
    const rateInput = lineItem.querySelector('.line-item-rate, input[name*="[rate]"]')
    const amountDisplay = lineItem.querySelector('.line-item-amount')
    const removeButton = lineItem.querySelector('.remove-line-item')

    const updateAmount = () => {
      if (quantityInput && rateInput && amountDisplay) {
        const quantity = parseFloat(quantityInput.value) || 0
        const rate = parseFloat(rateInput.value) || 0
        const amount = (quantity * rate).toFixed(2)
        amountDisplay.textContent = '$' + amount
      }
    }

    if (quantityInput) quantityInput.addEventListener('input', updateAmount)
    if (rateInput) rateInput.addEventListener('input', updateAmount)
    if (removeButton) {
      removeButton.addEventListener('click', () => {
        // Uncheck corresponding time entry checkbox if exists
        const timeEntryId = lineItem.dataset.timeEntryId
        if (timeEntryId) {
          const checkbox = document.querySelector(`input[data-time-entry-id="${timeEntryId}"]`)
          if (checkbox) checkbox.checked = false
        }
        lineItem.remove()
        this.updateEmptyState()
      })
    }

    updateAmount()
  }

  updateEmptyState() {
    if (!this.hasEmptyStateTarget) return

    const hasLineItems = this.manualLineItemsTarget.querySelectorAll('.line-item-row').length > 0
    this.emptyStateTarget.style.display = hasLineItems ? 'none' : 'block'
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    editTitle: { type: String, default: "Termin bearbeiten" },
    newTitle: { type: String, default: "Neuer Termin" }
  }

  static targets = [
    "sheet", "backdrop", "form", "customerId", "customerSearch", "customerResults",
    "customerSheet", "customerOverlay", "customerForm", "customerName",
    "customerMobile", "customerEmail", "customerErrors",
    "startDate", "startTime", "endDate", "endTime", "notes", "errors", "sheetTitle"
  ]

  connect() {
    this.searchTimeout = null
    this.selectedCustomer = null
    this.editingEventId = null
  }

  openForEdit(eventData) {
    this.editingEventId = String(eventData.id)
    const start = new Date(eventData.start)
    const end = eventData.end ? new Date(eventData.end) : this.addMinutes(start, 30)
    this.startDateTarget.value = start.toISOString().split("T")[0]
    this.startTimeTarget.value = start.toTimeString().slice(0, 5)
    this.endDateTarget.value = end.toISOString().split("T")[0]
    this.endTimeTarget.value = end.toTimeString().slice(0, 5)
    const customerId = eventData.extendedProps?.customer_id
    const customerName = eventData.extendedProps?.name || eventData.title || ""
    this.customerIdTarget.value = customerId || ""
    this.customerSearchTarget.value = customerName
    this.notesTarget.value = eventData.extendedProps?.notes?.trim() || ""
    this.errorsTarget.innerHTML = ""
    this.selectedCustomer = customerId ? { id: customerId, name: customerName } : null
    if (this.hasSheetTitleTarget) this.sheetTitleTarget.textContent = this.editTitleValue
    this.customerSearchTarget.disabled = true
    this.sheetTarget.classList.add("mct-sheet-open")
    this.backdropTarget.classList.add("mct-sheet-backdrop-visible")
    document.body.style.overflow = "hidden"
  }

  open(event) {
    const now = new Date()
    const startAt = this.nextFullHour(now)
    const endAt = this.addMinutes(startAt, 60)
    this.startDateTarget.value = startAt.toISOString().split("T")[0]
    this.startTimeTarget.value = startAt.toTimeString().slice(0, 5)
    this.endDateTarget.value = endAt.toISOString().split("T")[0]
    this.endTimeTarget.value = endAt.toTimeString().slice(0, 5)
    this.editingEventId = null
    if (this.hasSheetTitleTarget) this.sheetTitleTarget.textContent = this.newTitleValue
    this.clearForm()
    this.sheetTarget.classList.add("mct-sheet-open")
    this.backdropTarget.classList.add("mct-sheet-backdrop-visible")
    document.body.style.overflow = "hidden"
  }

  close() {
    this.editingEventId = null
    if (this.hasCustomerSearchTarget) this.customerSearchTarget.disabled = false
    this.sheetTarget.classList.remove("mct-sheet-open")
    this.backdropTarget.classList.remove("mct-sheet-backdrop-visible")
    this.closeCustomerSheet()
    document.body.style.overflow = ""
  }

  searchCustomer() {
    clearTimeout(this.searchTimeout)
    const q = this.customerSearchTarget?.value?.trim()
    if (!q || q.length < 2) {
      this.customerResultsTarget.innerHTML = ""
      return
    }
    this.searchTimeout = setTimeout(() => this.fetchCustomers(q), 200)
  }

  onCustomerSearchFocus() {
    if (this.customerSearchTarget.readOnly) {
      this.customerIdTarget.value = ""
      this.customerSearchTarget.value = ""
      this.customerSearchTarget.readOnly = false
    } else {
      const q = this.customerSearchTarget?.value?.trim()
      if (q && q.length >= 2) this.fetchCustomers(q)
    }
  }

  async fetchCustomers(q) {
    const url = `/resources/mobile/customers?q=${encodeURIComponent(q)}`
    try {
      const res = await fetch(url)
      const customers = await res.json()
      this.renderCustomerResults(customers)
    } catch (e) {
      this.customerResultsTarget.innerHTML = '<div class="mct-result-item mct-result-new">Neuer Kunde anlegen</div>'
    }
  }

  renderCustomerResults(customers) {
    let html = ""
    if (Array.isArray(customers) && customers.length > 0) {
      customers.forEach((c) => {
        html += `<div class="mct-result-item" data-id="${c.id}" data-name="${(c.name || "").replace(/"/g, "&quot;")}" data-mobile="${c.mobile_number || ""}" data-email="${c.email || ""}" data-action="click->mobile-calendar-entry-form#selectCustomer">${c.name || "—"} ${c.mobile_number ? `(${c.mobile_number})` : ""}</div>`
      })
    }
    html += '<div class="mct-result-item mct-result-new" data-action="click->mobile-calendar-entry-form#showCreateCustomer">+ Neuer Kunde</div>'
    this.customerResultsTarget.innerHTML = html
  }

  selectCustomer(event) {
    const el = event.currentTarget
    const id = el.dataset.id
    const name = el.dataset.name
    this.customerIdTarget.value = id
    this.customerSearchTarget.value = name
    this.customerSearchTarget.readOnly = true
    this.customerResultsTarget.innerHTML = ""
    this.selectedCustomer = { id, name }
  }

  showCreateCustomer(event) {
    const searchText = this.customerSearchTarget?.value?.trim() || ""
    this.customerResultsTarget.innerHTML = ""
    this.customerNameTarget.value = searchText
    this.customerMobileTarget.value = ""
    this.customerEmailTarget.value = ""
    this.customerErrorsTarget.innerHTML = ""
    this.customerSheetTarget.classList.add("mct-sheet-open")
    this.customerOverlayTarget.classList.add("mct-customer-overlay-visible")
    // Block interaction with the calendar entry form (grey it out); customer form stays interactive
    this.sheetTarget.classList.add("mct-sheet-blocked")
    this.backdropTarget.classList.add("mct-sheet-blocked")
  }

  closeCustomerSheet() {
    this.customerSheetTarget.classList.remove("mct-sheet-open")
    this.customerOverlayTarget.classList.remove("mct-customer-overlay-visible")
    this.sheetTarget.classList.remove("mct-sheet-blocked")
    this.backdropTarget.classList.remove("mct-sheet-blocked")
  }

  async submitCustomer(event) {
    event.preventDefault()
    this.customerErrorsTarget.innerHTML = ""

    const nameStr = this.customerNameTarget.value?.trim()
    const mobile = this.customerMobileTarget.value?.trim()
    const email = this.customerEmailTarget.value?.trim()

    if (!nameStr || !mobile) {
      this.customerErrorsTarget.textContent = "Name und Handynummer sind erforderlich."
      return
    }

    const parts = nameStr.split(/\s+/).filter(Boolean)
    const firstName = parts[0] || ""
    const lastName = parts.length > 1 ? parts.slice(1).join(" ") : firstName

    const payload = {
      first_name: firstName,
      last_name: lastName,
      mobile_number: mobile,
      email: email || "",
      salutation: "female",
    }

    const csrfToken = document.querySelector('[name="csrf-token"]')?.content
    try {
      const res = await fetch("/resources/mobile/customers", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
          Accept: "application/json",
        },
        body: JSON.stringify(payload),
      })

      const data = await res.json().catch(() => ({}))
      if (res.ok) {
        this.customerIdTarget.value = data.id
        this.customerSearchTarget.value = data.name
        this.customerSearchTarget.readOnly = true
        this.closeCustomerSheet()
      } else {
        const errMsg = data?.errors
          ? (Array.isArray(data.errors) ? data.errors.join(", ") : JSON.stringify(data.errors))
          : "Fehler beim Anlegen des Kunden."
        this.customerErrorsTarget.textContent = errMsg
      }
    } catch (e) {
      this.customerErrorsTarget.textContent = "Netzwerkfehler. Bitte erneut versuchen."
    }
  }

  async submit(event) {
    event.preventDefault()
    this.errorsTarget.innerHTML = ""

    const customerId = this.customerIdTarget.value?.trim()

    if (!customerId) {
      this.errorsTarget.textContent = "Bitte Kunde auswählen oder anlegen."
      return
    }

    const startDate = this.startDateTarget.value
    const startTime = this.startTimeTarget.value
    const endDate = this.endDateTarget.value
    const endTime = this.endTimeTarget.value

    const startAt = `${startDate}T${startTime}:00`
    const endAt = `${endDate}T${endTime}:00`

    const payload = {
      start_at: startAt,
      end_at: endAt,
      notes: this.notesTarget?.value?.trim() || "",
    }

    payload.customer_id = parseInt(customerId, 10)

    const csrfToken = document.querySelector('[name="csrf-token"]')?.content
    const base = window.location.pathname.replace(/\/[^/]*$/, "") || ""
    const isEdit = this.editingEventId != null
    const url = isEdit
      ? `${base}/resources/mobile/calendar_entries/${this.editingEventId}`
      : `${base}/resources/mobile/calendar_entries`
    const method = isEdit ? "PATCH" : "POST"

    try {
      const res = await fetch(url, {
        method,
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
          Accept: "application/json",
        },
        body: JSON.stringify(payload),
      })

      const data = await res.json().catch(() => ({}))
      if (res.ok) {
        this.close()
        const calendarController = this.application.getControllerForElementAndIdentifier(
          document.querySelector("[data-controller~='mobile-calendar']"),
          "mobile-calendar"
        )
        if (calendarController?.fetchEvents) calendarController.fetchEvents()
      } else {
        const errMsg = data?.errors
          ? (Array.isArray(data.errors) ? data.errors.join(", ") : JSON.stringify(data.errors))
          : "Fehler beim Speichern."
        this.errorsTarget.textContent = errMsg
      }
    } catch (e) {
      this.errorsTarget.textContent = "Netzwerkfehler. Bitte erneut versuchen."
    }
  }

  refreshDatetimePickers() {
    this.element.querySelectorAll('[data-controller~="mobile-calendar-datetime-picker"]').forEach((el) => {
      const ctrl = this.application.getControllerForElementAndIdentifier(el, "mobile-calendar-datetime-picker")
      if (ctrl?.refreshDisplay) ctrl.refreshDisplay()
    })
  }

  clearForm() {
    this.customerIdTarget.value = ""
    this.customerSearchTarget.value = ""
    this.customerSearchTarget.readOnly = false
    this.customerSearchTarget.disabled = false
    this.customerResultsTarget.innerHTML = ""
    this.notesTarget.value = ""
    this.errorsTarget.innerHTML = ""
    this.selectedCustomer = null
    this.closeCustomerSheet()
  }

  addMinutes(d, min) {
    return new Date(d.getTime() + min * 60000)
  }

  nextFullHour(d) {
    const next = new Date(d)
    next.setMinutes(0, 0, 0)
    next.setHours(next.getHours() + 1)
    return next
  }

  startChanged() {
    const startDate = this.startDateTarget.value
    const startTime = this.startTimeTarget.value
    const endDate = this.endDateTarget.value
    const endTime = this.endTimeTarget.value
    if (!startDate || !startTime || !endDate || !endTime) return
    const start = new Date(`${startDate}T${startTime}:00`)
    const end = new Date(`${endDate}T${endTime}:00`)
    if (end <= start) {
      const newEnd = this.addMinutes(start, 60)
      this.endDateTarget.value = newEnd.toISOString().split("T")[0]
      this.endTimeTarget.value = newEnd.toTimeString().slice(0, 5)
    }
  }
}

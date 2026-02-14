import { Controller } from "@hotwired/stimulus"

// Vanilla calendar like wellness appointment - no FullCalendar
const MONTH_NAMES = [
  "Januar", "Februar", "März", "April", "Mai", "Juni",
  "Juli", "August", "September", "Oktober", "November", "Dezember"
]
const DAY_NAMES = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]

export default class extends Controller {
  static targets = [
    "grid", "monthYear", "eventsList", "eventsTitle",
    "confirmModal", "confirmModalTitle", "confirmModalMessage", "confirmModalYesLabel", "confirmModalNoLabel"
  ]
  static values = {
    approveLabel: { type: String, default: "Approve" },
    cancelEntryLabel: { type: String, default: "Cancel appointment" },
    editLabel: { type: String, default: "Edit" },
    saveLabel: { type: String, default: "Save" },
    notesLabel: { type: String, default: "Note" },
    notesPlaceholder: { type: String, default: "Add note..." },
    cancelConfirmTitle: { type: String, default: "Cancel appointment?" },
    cancelConfirmMessage: { type: String, default: "Do you really want to cancel this appointment?" },
    cancelConfirmYes: { type: String, default: "Yes, cancel appointment" },
    cancelConfirmNo: { type: String, default: "Cancel" },
    resourceBase: { type: String, default: "/resources/issue_calendar_entries" }
  }

  connect() {
    this.currentYear = new Date().getFullYear()
    this.currentMonth = new Date().getMonth()
    this.selectedDate = new Date()
    this.events = []
    this.selectedEventId = null

    this.boundHandleEventListClick = (ev) => this.handleEventListClick(ev)
    this.boundHandleEventListInput = (ev) => this.handleEventListInput(ev)
    if (this.hasEventsListTarget) {
      this.eventsListTarget.addEventListener("click", this.boundHandleEventListClick)
      this.eventsListTarget.addEventListener("input", this.boundHandleEventListInput)
    }

    this.fetchEvents()
    this.renderCalendar()
    this.updateEventsList()
  }

  disconnect() {
    if (this.hasEventsListTarget) {
      this.eventsListTarget.removeEventListener("click", this.boundHandleEventListClick)
      this.eventsListTarget.removeEventListener("input", this.boundHandleEventListInput)
    }
  }

  changeMonth(delta) {
    this.currentMonth += delta
    if (this.currentMonth < 0) {
      this.currentMonth = 11
      this.currentYear--
    } else if (this.currentMonth > 11) {
      this.currentMonth = 0
      this.currentYear++
    }
    const today = new Date()
    const todayInView =
      today.getFullYear() === this.currentYear && today.getMonth() === this.currentMonth
    this.selectedDate = todayInView
      ? new Date(today.getFullYear(), today.getMonth(), today.getDate())
      : new Date(this.currentYear, this.currentMonth, 1)
    this.selectedEventId = null
    this.fetchEvents()
  }

  goToToday() {
    const today = new Date()
    this.currentYear = today.getFullYear()
    this.currentMonth = today.getMonth()
    this.selectedDate = new Date(today.getFullYear(), today.getMonth(), today.getDate())
    this.fetchEvents()
  }

  renderCalendar() {
    if (!this.hasGridTarget) return
    const grid = this.gridTarget

    const date = new Date(this.currentYear, this.currentMonth, 1)
    const firstDayOfWeek = date.getDay()
    const firstDay = firstDayOfWeek === 0 ? 6 : firstDayOfWeek - 1 // Monday-based
    const daysInMonth = new Date(this.currentYear, this.currentMonth + 1, 0).getDate()
    const today = new Date()
    const currentDate = new Date(today.getFullYear(), today.getMonth(), today.getDate())

    // Update month/year header
    if (this.hasMonthYearTarget) {
      this.monthYearTarget.textContent = `${MONTH_NAMES[this.currentMonth]} ${this.currentYear}`
    }

    grid.innerHTML = ""

    // Day headers
    DAY_NAMES.forEach((name) => {
      const header = document.createElement("div")
      header.className = "mct-day-header"
      header.textContent = name
      grid.appendChild(header)
    })

    // Previous month padding
    const prevMonthDays = new Date(this.currentYear, this.currentMonth, 0).getDate()
    for (let i = firstDay - 1; i >= 0; i--) {
      const day = document.createElement("div")
      day.className = "mct-day mct-day-other"
      day.textContent = prevMonthDays - i
      grid.appendChild(day)
    }

    // Current month days
    for (let i = 1; i <= daysInMonth; i++) {
      const day = document.createElement("div")
      const dayDate = new Date(this.currentYear, this.currentMonth, i)

      day.className = "mct-day"
      day.dataset.year = this.currentYear
      day.dataset.month = this.currentMonth
      day.dataset.day = i

      const numEl = document.createElement("span")
      numEl.className = "mct-day-num"
      numEl.textContent = i

      const isToday = this.isSameDay(dayDate, currentDate)
      const isSelected = this.isSameDay(dayDate, this.selectedDate)

      if (isToday) day.classList.add("mct-day-today")
      if (isSelected) day.classList.add("mct-day-selected")

      day.appendChild(numEl)

      // Event dots
      const dayEvents = this.getEventsForDate(dayDate)
      if (dayEvents.length > 0) {
        const dotsEl = document.createElement("div")
        dotsEl.className = "mct-day-dots"
        dayEvents.slice(0, 5).forEach((ev) => {
          const dot = document.createElement("span")
          dot.className = "mct-event-dot"
          dot.style.backgroundColor = this.eventDotColor(ev)
          dotsEl.appendChild(dot)
        })
        day.appendChild(dotsEl)
      }

      day.addEventListener("click", () => this.selectDate(dayDate))
      grid.appendChild(day)
    }

    // Next month padding (6 rows * 7 = 42 cells)
    const totalCells = grid.children.length
    const remaining = 42 - totalCells
    for (let i = 1; i <= Math.min(remaining, 14); i++) {
      const day = document.createElement("div")
      day.className = "mct-day mct-day-other"
      day.textContent = i
      grid.appendChild(day)
    }
  }

  selectDate(date) {
    this.selectedDate = new Date(date.getFullYear(), date.getMonth(), date.getDate())
    this.fetchEvents()
  }

  isSameDay(d1, d2) {
    return (
      d1.getDate() === d2.getDate() &&
      d1.getMonth() === d2.getMonth() &&
      d1.getFullYear() === d2.getFullYear()
    )
  }

  getEventsForDate(date) {
    const y = date.getFullYear()
    const m = date.getMonth()
    const d = date.getDate()
    return this.events.filter((ev) => {
      const start = new Date(ev.start)
      return start.getFullYear() === y && start.getMonth() === m && start.getDate() === d
    })
  }

  async fetchEvents() {
    const year = this.currentYear
    const month = this.currentMonth
    const start = new Date(year, month - 1, 1)
    const end = new Date(year, month + 2, 0)
    const startStr = start.toISOString().split("T")[0]
    const endStr = end.toISOString().split("T")[0]
    const url = `/resources/calendar_entries?start=${startStr}&end=${endStr}`

    try {
      const response = await fetch(url)
      this.events = await response.json()
      this.renderCalendar()
      this.updateEventsList()
    } catch (error) {
      console.error("Mobile calendar fetch error:", error)
    }
  }

  updateEventsList() {
    if (!this.hasEventsListTarget) return

    const date = this.selectedDate
    const dayEvents = this.getEventsForDate(date)

    if (this.hasEventsTitleTarget) {
      this.eventsTitleTarget.textContent = date.toLocaleDateString("de-DE", {
        weekday: "long",
        day: "numeric",
        month: "long",
      })
    }

    if (dayEvents.length === 0) {
      this.eventsListTarget.innerHTML = '<p class="mct-no-events">Keine Ereignisse</p>'
    } else {
      const sorted = [...dayEvents].sort((a, b) => new Date(a.start) - new Date(b.start))
      this.eventsListTarget.innerHTML = sorted
        .map(
          (e) => this.renderEventRow(e)
        )
        .join("")
    }
  }

  renderEventRow(e) {
    const id = e.id
    const isSelected = this.selectedEventId === String(id)
    const notes = e.extendedProps?.notes?.trim() || ""
    const isCanceld = e.extendedProps?.status === "canceld"
    const isConfirmed = e.extendedProps?.confirmed

    const avoBtnPrimary = "button-component inline-flex flex-grow-0 items-center font-semibold leading-6 fill-current whitespace-nowrap transition duration-100 cursor-pointer border justify-center active:outline active:outline-1 rounded bg-primary-500 text-white border-primary-500 hover:bg-primary-600 hover:border-primary-600 active:border-primary-600 active:outline-primary-600 active:bg-primary-600 px-3 py-1.5 text-sm"
    const saveBtnHtml = !isCanceld
      ? `<div class="mct-event-notes-actions"><button type="button" class="${avoBtnPrimary} is-hidden" data-event-id="${id}" data-action="save" data-original-notes="${this.escapeHtml(notes)}"><span>${this.escapeHtml(this.saveLabelValue)}</span></button></div>`
      : ""
    const notesBlock = `
      <div class="mct-event-notes-section">
        <textarea class="mct-event-notes-input" data-event-id="${id}" placeholder="${this.escapeHtml(this.notesPlaceholderValue)}" rows="2" ${isCanceld ? "readonly" : ""}>${this.escapeHtml(notes)}</textarea>
        ${saveBtnHtml}
      </div>
    `
    let entryActionsBlock = ""
    if (!isCanceld) {
      const entryActions = []
      if (!isConfirmed) {
        entryActions.push(`<button type="button" class="mct-event-btn mct-event-btn--approve" data-event-id="${id}" data-action="approve">${this.escapeHtml(this.approveLabelValue)}</button>`)
      } else {
        entryActions.push(`<button type="button" class="mct-event-btn mct-event-btn--cancel-entry" data-event-id="${id}" data-action="cancel">${this.escapeHtml(this.cancelEntryLabelValue)}</button>`)
      }
      entryActions.push(`<button type="button" class="${avoBtnPrimary}" data-event-id="${id}" data-action="edit">${this.escapeHtml(this.editLabelValue)}</button>`)
      entryActionsBlock = `
        <div class="mct-event-detail-divider"></div>
        <div class="mct-event-entry-actions-section">
          <div class="mct-event-entry-actions">${entryActions.join("")}</div>
        </div>
      `
    }

    const detailHtml = isSelected ? `
      <div class="mct-event-detail" data-event-id="${id}">
        ${notesBlock}
        ${entryActionsBlock}
      </div>
    ` : ""

    return `
      <div class="mct-event-wrapper ${isSelected ? "mct-event-wrapper--selected" : ""}" data-event-id="${id}">
        <div class="mct-event-row ${this.eventRowClass(e)}">
          <span class="mct-event-dot-inline" style="background-color: ${this.eventDotColor(e)}"></span>
          <div class="mct-event-main">
            <div class="mct-event-primary">
              <span class="mct-event-time">${this.formatTime(e.start, e.end, e.allDay)}</span>
              <span class="mct-event-title">${this.escapeHtml(e.title || e.extendedProps?.name || "Termin")}</span>
            </div>
          </div>
        </div>
        ${detailHtml}
      </div>
    `
  }

  openEditForm(eventId) {
    const ev = this.events.find((e) => String(e.id) === String(eventId))
    if (!ev) return
    const formElement = document.querySelector("[data-controller~='mobile-calendar-entry-form']")
    const formController = formElement
      ? this.application.getControllerForElementAndIdentifier(formElement, "mobile-calendar-entry-form")
      : null
    if (formController?.openForEdit) formController.openForEdit(ev)
  }

  handleEventListClick(event) {
    const btn = event.target.closest("button[data-action]")
    if (btn) {
      event.preventDefault()
      event.stopPropagation()
      const id = btn.dataset.eventId
      const action = btn.dataset.action
      if (action === "approve") this.confirmEvent(id)
      if (action === "cancel") this.cancelEvent(id)
      if (action === "save") this.saveNotes(id, btn)
      if (action === "edit") this.openEditForm(id)
      return
    }

    const wrapper = event.target.closest(".mct-event-wrapper[data-event-id]")
    if (!wrapper) return
    const textarea = event.target.closest(".mct-event-notes-input")
    if (textarea) return
    const id = wrapper.dataset.eventId
    this.selectedEventId = this.selectedEventId === id ? null : id
    this.updateEventsList()
  }

  handleEventListInput(event) {
    const textarea = event.target.closest(".mct-event-notes-input")
    if (!textarea) return
    const detail = textarea.closest(".mct-event-detail")
    const saveBtn = detail?.querySelector("button[data-action='save']")
    if (!saveBtn) return
    const original = saveBtn.dataset.originalNotes ?? ""
    const current = textarea.value
    saveBtn.classList.toggle("is-hidden", current === original)
  }

  async saveNotes(id, btn) {
    const detail = btn.closest(".mct-event-detail")
    const textarea = detail?.querySelector(".mct-event-notes-input")
    const notes = textarea?.value ?? ""
    const csrf = document.querySelector('[name="csrf-token"]')?.content
    const base = window.location.pathname.replace(/\/[^/]*$/, "") || ""
    const url = `${base}/resources/mobile/calendar_entries/${id}`
    try {
      const res = await fetch(url, {
        method: "PATCH",
        headers: { "X-CSRF-Token": csrf, "Content-Type": "application/json", Accept: "application/json" },
        body: JSON.stringify({ notes })
      })
      if (res.ok) {
        btn.dataset.originalNotes = notes
        btn.classList.add("is-hidden")
        const ev = this.events.find((e) => String(e.id) === String(id))
        if (ev && ev.extendedProps) ev.extendedProps.notes = notes
      } else {
        const data = await res.json().catch(() => ({}))
        alert(data?.errors?.join?.(", ") || "Fehler")
      }
    } catch (e) {
      alert("Netzwerkfehler")
    }
  }

  async confirmEvent(id) {
    const csrf = document.querySelector('[name="csrf-token"]')?.content
    const base = window.location.pathname.replace(/\/[^/]*$/, "") || ""
    const url = `${base}/resources/mobile/calendar_entries/${id}/confirm`
    try {
      const res = await fetch(url, {
        method: "POST",
        headers: { "X-CSRF-Token": csrf, "Content-Type": "application/json", Accept: "application/json" },
        body: "{}"
      })
      if (res.ok) {
        this.selectedEventId = null
        this.fetchEvents()
      } else {
        const data = await res.json().catch(() => ({}))
        alert(data?.errors?.join?.(", ") || "Fehler")
      }
    } catch (e) {
      alert("Netzwerkfehler")
    }
  }

  cancelEvent(id) {
    this._pendingCancelEventId = id
    if (this.hasConfirmModalTitleTarget) this.confirmModalTitleTarget.textContent = this.cancelConfirmTitleValue
    if (this.hasConfirmModalMessageTarget) this.confirmModalMessageTarget.textContent = this.cancelConfirmMessageValue
    if (this.hasConfirmModalYesLabelTarget) this.confirmModalYesLabelTarget.textContent = this.cancelConfirmYesValue
    if (this.hasConfirmModalNoLabelTarget) this.confirmModalNoLabelTarget.textContent = this.cancelConfirmNoValue
    if (this.hasConfirmModalTarget) {
      this.confirmModalTarget.classList.add("mct-confirm-modal-visible")
      this.confirmModalTarget.setAttribute("aria-hidden", "false")
    }
  }

  closeCancelConfirm() {
    this._pendingCancelEventId = null
    if (this.hasConfirmModalTarget) {
      this.confirmModalTarget.classList.remove("mct-confirm-modal-visible")
      this.confirmModalTarget.setAttribute("aria-hidden", "true")
    }
  }

  async confirmCancelEntry() {
    const id = this._pendingCancelEventId
    this.closeCancelConfirm()
    if (!id) return
    const csrf = document.querySelector('[name="csrf-token"]')?.content
    const base = window.location.pathname.replace(/\/[^/]*$/, "") || ""
    const url = `${base}/resources/mobile/calendar_entries/${id}/cancel`
    try {
      const res = await fetch(url, {
        method: "POST",
        headers: { "X-CSRF-Token": csrf, "Content-Type": "application/json", Accept: "application/json" },
        body: "{}"
      })
      if (res.ok) {
        this.selectedEventId = null
        this.fetchEvents()
      } else {
        const data = await res.json().catch(() => ({}))
        alert(data?.errors?.join?.(", ") || "Fehler")
      }
    } catch (e) {
      alert("Netzwerkfehler")
    }
  }

  eventRowClass(e) {
    if (e.extendedProps?.status === "canceld") return "mct-event-row--canceld"
    if (!e.extendedProps?.confirmed) return "mct-event-row--unconfirmed"
    return "mct-event-row--confirmed"
  }

  eventDotColor(e) {
    if (e.extendedProps?.status === "canceld") return "#dc2626"
    return e.backgroundColor || e.borderColor || e.color || "#d1edbc"
  }

  escapeHtml(str) {
    if (str == null) return ""
    const div = document.createElement("div")
    div.textContent = str
    return div.innerHTML
  }

  formatTime(startStr, endStr, allDay) {
    if (allDay) return "Ganztägig"
    const start = new Date(startStr)
    const end = endStr ? new Date(endStr) : null
    const timeStr = start.toLocaleTimeString("de-DE", {
      hour: "2-digit",
      minute: "2-digit",
    })
    if (end) {
      const endFmt = end.toLocaleTimeString("de-DE", {
        hour: "2-digit",
        minute: "2-digit",
      })
      return `${timeStr} – ${endFmt}`
    }
    return timeStr
  }

  // Stimulus actions for buttons (use data-action)
  prevMonth() {
    this.changeMonth(-1)
  }

  nextMonth() {
    this.changeMonth(1)
  }
}

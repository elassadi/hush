import { Controller } from "@hotwired/stimulus"

// Vanilla calendar like wellness appointment - no FullCalendar
const MONTH_NAMES = [
  "Januar", "Februar", "März", "April", "Mai", "Juni",
  "Juli", "August", "September", "Oktober", "November", "Dezember"
]
const DAY_NAMES = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]

export default class extends Controller {
  static targets = ["grid", "monthYear", "eventsList", "eventsTitle"]

  connect() {
    this.currentYear = new Date().getFullYear()
    this.currentMonth = new Date().getMonth()
    this.selectedDate = new Date()
    this.events = []

    this.fetchEvents()
    this.renderCalendar()
    this.updateEventsList()
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
    this.renderCalendar()
    this.updateEventsList()
  }

  goToToday() {
    const today = new Date()
    this.currentYear = today.getFullYear()
    this.currentMonth = today.getMonth()
    this.selectedDate = new Date(today.getFullYear(), today.getMonth(), today.getDate())
    this.renderCalendar()
    this.updateEventsList()
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
          dot.style.backgroundColor = ev.backgroundColor || ev.borderColor || ev.color || "#3b82f6"
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
    this.renderCalendar()
    this.updateEventsList()
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
    const now = new Date()
    const start = new Date(now.getFullYear(), now.getMonth() - 1, 1)
    const end = new Date(now.getFullYear(), now.getMonth() + 2, 0)
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
      this.eventsListTarget.innerHTML = dayEvents
        .map(
          (e) => `
        <div class="mct-event-row">
          <span class="mct-event-dot-inline" style="background-color: ${e.backgroundColor || e.borderColor || e.color || "#3b82f6"}"></span>
          <span class="mct-event-time">${this.formatTime(e.start, e.end, e.allDay)}</span>
          <span class="mct-event-title">${e.title || e.extendedProps?.name || "Termin"}</span>
        </div>
      `
        )
        .join("")
    }
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

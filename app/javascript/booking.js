// Booking API Configuration
//const BOOKING_API_TOKEN = 'ahSqgbKEcdk3AHnUK2ZTPCbT3mv2oEmzReeG';
const MERCHANT_ID = 2;
const API_BASE_URL = window.location.origin || 'http://localhost:3001';

// Store available dates
let availableDates = [];
let isLoadingDates = false;

/**
 * Fetch available dates from API
 * @param {Date} startDate - Start date for the range
 * @param {Date} endDate - End date for the range
 * @returns {Promise<Array<string>>} Array of available date strings
 */
async function fetchAvailableDates(startDate, endDate) {
  if (isLoadingDates) {
    return availableDates; // Return cached if already loading
  }

  isLoadingDates = true;

  try {
    // Format dates as YYYY-MM-DD
    const formatDate = (date) => {
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      return `${year}-${month}-${day}`;
    };

    const startDateStr = formatDate(startDate);
    const endDateStr = formatDate(endDate);

    const url = `${API_BASE_URL}/api/partner/calendar_entries/available_slots?start_date=${startDateStr}&end_date=${endDateStr}&merchant_id=${MERCHANT_ID}&days_only=true`;

    const response = await fetch(url, {
      method: 'GET',
      headers: {
        'Authorization': `Token token=${window.bookingToken}`,
        'Content-Type': 'application/json'
      }
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    availableDates = Array.isArray(data) ? data : [];
    return availableDates;
  } catch (error) {
    console.error('Error fetching available dates:', error);
    // Return empty array on error, which will disable all dates
    return [];
  } finally {
    isLoadingDates = false;
  }
}

/**
 * Check if a date is available
 * @param {Date} date - Date to check
 * @returns {boolean} True if date is available
 */
function isDateAvailable(date) {
  // If dates haven't been loaded yet, return false to disable all dates until loaded
  // This prevents showing all dates as available before the API call completes
  if (availableDates.length === 0) {
    return false; // Disable dates until we know which are available
  }

  const formatDate = (date) => {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  };

  const dateStr = formatDate(date);
  return availableDates.includes(dateStr);
}

/**
 * Fetch available dates for a month range (current month + 2 months ahead)
 * @param {number} month - Month index (0-11)
 * @param {number} year - Year
 */
async function fetchAvailableDatesForMonth(month, year) {
  const startDate = new Date(year, month, 1);
  const endDate = new Date(year, month + 2, 0); // End of month + 2 months ahead

  await fetchAvailableDates(startDate, endDate);

  // Trigger calendar re-render if it exists
  if (typeof renderCalendar === 'function') {
    renderCalendar();
  }
}

/**
 * Initialize available dates when step 2 is shown
 */
async function initializeAvailableDates() {
  const today = new Date();
  const startDate = new Date(today.getFullYear(), today.getMonth(), 1);
  const endDate = new Date(today.getFullYear(), today.getMonth() + 2, 0);

  await fetchAvailableDates(startDate, endDate);

  // Trigger calendar re-render after dates are loaded
  if (typeof renderCalendar === 'function') {
    renderCalendar();
  }
}

// Export functions for use in other scripts
if (typeof window !== 'undefined') {
  window.bookingAPI = {
    fetchAvailableDates,
    isDateAvailable,
    fetchAvailableDatesForMonth,
    initializeAvailableDates,
    getAvailableDates: () => availableDates
  };
}

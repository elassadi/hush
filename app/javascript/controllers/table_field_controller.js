import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["headerCheckbox", "row", "rowCheckbox"];

  connect() {
    console.log("Table Field Controller connected");
  }

  toggleAll(event) {
    const isChecked = event.target.checked;
    this.rowCheckboxTargets.forEach((checkbox) => {
      checkbox.checked = isChecked;
    });
  }

  selectRow(event) {
    // Prevent triggering when clicking on the checkbox itself
    if (event.target.type === "checkbox") return;

    const checkbox = event.currentTarget.querySelector('input[type="checkbox"]');
    checkbox.checked = !checkbox.checked;
  }
}
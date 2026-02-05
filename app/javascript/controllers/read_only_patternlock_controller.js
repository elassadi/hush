import { Controller } from "@hotwired/stimulus"


import "jquery"; // this import first
import 'patternlock' // <- import first


export default class extends Controller {

  static targets = ['unlockPatternTextWrapper', 'unlockPatternHiddenInput',"unlockPatternTextWrapper"]
  static values = { view: String }




  connect() {

    if (this.viewValue != 'show')
      return

    if (!this.fetchUnlockPatternValue())
      return


    if (isNaN(this.fetchUnlockPatternValue())) {
      return
    }

    this.lock = new PatternLock("#lock", {
      enableSetPattern: true,
      radius:14,
      margin:10,
      vibrate: false
    });



    this.lock.setPattern(this.fetchUnlockPatternValue());
    this.lock.success();
    this.disablePatternLock();
    //this.hideElements(this.unlockPatternTextWrapperTarget)

  }

  // Function to disable the pattern lock
  disablePatternLock() {

    // Select the SVG element
    const svgElement = document.getElementById('lock');

    // Function to prevent default action and stop propagation
    function disableEvent(e) {
        e.preventDefault();
        e.stopPropagation();
    }

    // Disable touchstart and mousedown events
    svgElement.addEventListener('touchstart', disableEvent, true);
    svgElement.addEventListener('mousedown', disableEvent, true);
  }




  fetchUnlockPatternValue() {



    // Access the target element
    let unlockPatternElement = undefined;
    let unlockPatternValue = undefined;
    // if (this.hasUnlockPatternTextWrapperTarget) {
    //   unlockPatternElement = this.unlockPatternTextWrapperTarget;
    //   unlockPatternValue = unlockPatternElement.textContent.replace(/\s+/g, ' ').trim();
    // }

    if (this.hasUnlockPatternHiddenInputTarget) {
      unlockPatternElement = this.unlockPatternHiddenInputTarget;
      unlockPatternValue = unlockPatternElement.value

    }

    if (!unlockPatternValue || this.validatePattern(unlockPatternValue) === false) {
      return null;
    }
    const refinedUnlockPatternValueMatch = unlockPatternValue.match(/\d+/);

    // Check if the match is found
    if (!refinedUnlockPatternValueMatch) {
        return null;
    } else {
        // Extract the matched value
        const refinedUnlockPatternValue = refinedUnlockPatternValueMatch[0];
      return refinedUnlockPatternValue;
    }
  }

  hideElements(elements) {
    Array(elements).flat().forEach((el) => {
      el.classList.add("hidden")
    })
  }

  validatePattern(pattern) {
    const minLength = 2;  // Example: minimum length for a valid pattern
    const maxLength = 9;  // Example: maximum length for a valid pattern
    const patternLength = pattern.length;

    // Check if the pattern length is within the allowed range
    if (patternLength < minLength) {
      return false;
    }

    if (patternLength > maxLength) {
      return false;
    }

    // Check if the pattern contains only digits 1-9
    const validPatternRegex = /^[1-9]+$/;
    if (!validPatternRegex.test(pattern)) {
      return false;
    }

    return true; // Pattern is valid
  }



}

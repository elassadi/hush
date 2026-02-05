import { Controller } from "@hotwired/stimulus"


import "jquery"; // this import first
import 'patternlock' // <- import first


export default class extends Controller {

  static targets = ['unlockPatternTextInput','unlockPatternTextWrapper' ]
  static values = { view: String }




  connect() {

    var that = this

    if (!this.hasUnlockPatternTextInputTarget)
      return


    this.lock = new PatternLock("#lock", {
      enableSetPattern: true,
      radius:14,
      margin:10,
      vibrate: false,
      onPattern: function(pattern) {


        window.debugme= pattern
        if (isNaN(pattern)) {
          that.unlockPatternTextInputTarget.value = null
        }else {
          that.unlockPatternTextInputTarget.value = pattern
        }
        this.success()
      }
    })


    if (this.hasUnlockPatternTextInputTarget && this.unlockPatternTextInputTarget.value){
      this.lock.setPattern(this.unlockPatternTextInputTarget.value);
      this.lock.success();
    }

    this.hideElements(this.unlockPatternTextWrapperTarget)
  }


  onFocus(event){
    let wrapper = document.getElementById("lockwrapper")
    if (!wrapper.classList.contains("hidden"))
      return
    this.showElements(wrapper)
  }

  keydown(event){
    if (event.key =="Escape") {
      let wrapper = document.getElementById("lockwrapper")
      this.hideElements(wrapper)
    }
  }

  hideElements(elements) {
    Array(elements).flat().forEach((el) => {
      el.classList.add("hidden")
    })
  }

  showElements(elements) {
    Array(elements).flat().forEach((el) => {
      el.classList.remove("hidden")
    })
  }


}

import { Controller } from "@hotwired/stimulus"


export default class extends Controller {

  static targets = ['commentableTriggerInput', "commentableInputWrapper","commentableTextArea","commentableCancelButton"]
  static values = { view: String }




  async connect() {
    const el = document.getElementById("has_many_field_show_comments")
    if (el)
      el.classList.add("hidden")

    this.boundUpdateCommentableFrame = this.updateCommentableFrame.bind(this)
    document.addEventListener("turbo:frame-load", this.boundUpdateCommentableFrame)

  }


  disconnect() {
    document.removeEventListener("turbo:frame-load", this.boundUpdateCommentableFrame)
  }

  updateCommentableFrame(event) {
    if (event.target.id == "has_many_field_show_comments"){
      var el = document.getElementById("commentable")
      if (el) {
        el.reload()
        //this.highlightCommentable()
      }
    }
  }


  async hideElements(elements) {
    Array(elements).flat().forEach((el) => {
      el.classList.add("hidden")
    })
  }

  async showElements(elements) {
    Array(elements).flat().forEach((el) => {
      el.classList.remove("hidden")
    })
  }

  commentableTriggerInputClicked(event) {
    //this.turbo_fetch(event)
    this.hideElements(this.commentableTriggerInputTarget)
    this.showElements(this.commentableInputWrapperTarget)
    this.commentableTextAreaTarget.focus();
    this.commentableTextAreaTarget.scrollIntoView();

  }

  commentableCancelButtonClicked (event){
    event.preventDefault();
    event.stopPropagation();
    this.showElements(this.commentableTriggerInputTarget)
    this.hideElements(this.commentableInputWrapperTarget)
  }

  commentableEscPressed(event){

    const keyName = event.key;

    if (keyName!="Escape")
      return
    this.commentableCancelButtonClicked(event)

  }

// __turbo_fetch (event) {
//     const   result = fetch("/resources/comments/new?modal_resource=true&via_child_resource=CommentResource&via_relation=commentable&via_relation_class=Issue&via_resource_id=10", {
//       method: 'GET',
//       headers: {
//         'X-CSRF-Token': this.token,
//         'Turbo-Frame': 'modal_resource',
//       },
//       credentials: 'same-origin'
//     })
//     .then (response => response.text())
//     .then(html => Turbo.renderStreamMessage(html));
//   }
}


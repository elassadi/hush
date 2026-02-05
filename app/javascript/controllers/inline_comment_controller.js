import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = [
    'inlineCommentTextArea', 'commentBox'
  ]
  static values = { view: String }



  async connect() {
    this.highlightCommentable()
  }

  autoResize(event) {
    var element = event.target
    const maxHeight = parseInt(getComputedStyle(element).maxHeight, 10);
    element.style.height = 'auto';
    element.style.overflow = 'hidden'; // Prevents scrollbar appearance during height adjustment

    if (element.scrollHeight > maxHeight) {
        element.style.height = `${maxHeight}px`;
        element.style.overflow = 'auto'; // Adds scrollbar when content exceeds max height
    } else {
        element.style.height = `${element.scrollHeight}px`;
    }
}


  showCommentInput() {
    const commentInput = document.getElementById("comment-input");
    const commentInputLabel = document.getElementById("comment-input-label");
    const commentArea = document.getElementById("comment-area");

    commentInput.classList.add("hidden");
    commentInputLabel.classList.remove("hidden");
    commentArea.classList.remove("hidden");
    this.inlineCommentTextAreaTarget.focus();
    commentArea.scrollIntoView({
      behavior: 'smooth', // Smooth scrolling
      block: 'center' // Vertically center the element
    });
  }

  handleKeydown(event) {
    const excludedKeys = ["ArrowUp", "ArrowDown", "ArrowLeft", "ArrowRight"];

    if (event.ctrlKey && event.key === "Enter") {
      return this.postComment();
    } else if (event.key === "Escape") {
      return this.cancelComment();
    } else if (excludedKeys.includes(event.key)) {
      return;
    }

    this.autoResize(event);
  }

  postComment() {
    const commentText = this.inlineCommentTextAreaTarget.value.trim();

    if (commentText) {
      // Handle comment post logic here (e.g., submit via AJAX or Turbo)

    }

    this.resetCommentInput();
  }


  highlightCommentable() {

    const el = document.getElementById("commentable");
    if (el) {
      const comments = el.querySelectorAll(".comment_article");
      if (comments.length > 0) {
        const lastComment = comments[comments.length - 1]; // Get the last comment

        // Scroll to the first comment
        lastComment.scrollIntoView({ behavior: "instant",
           block: 'nearest',
          inline: 'nearest'
           });
          lastComment.classList.add("highlight");

        setTimeout(() => {
          lastComment.classList.remove("highlight");
        }, 3000); // Duration of the highlight effect in milliseconds
      }

      // Remove the event listener after it's triggered
      el.removeEventListener('turbo:frame-load', this.highlightCommentable);
    }
  }

  postComment() {
    // Get the CSRF token from the meta tag
    const commentText = this.inlineCommentTextAreaTarget.value.trim();

    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    // Get the button element by its ID
    const submitButton = document.getElementById('submit-comment');

    // Extract the data attributes from the button
    const viaResourceId = submitButton.getAttribute('data-via-resource-id');
    const commentableType = submitButton.getAttribute('data-commentable-type');

    // Prepare the form data (similar to the data in the provided curl request)
    const formData = new FormData();
    formData.append('authenticity_token', csrfToken);
    formData.append('via_resource_id', viaResourceId); // Dynamically set from the button
    formData.append('via_relation', 'commentable');
    formData.append('modal_resource', 'true');
    formData.append('via_child_resource', 'CommentResource');
    formData.append('comment[commentable_type]', commentableType); // Dynamically set from the button
    formData.append('comment[commentable_id]', viaResourceId); // Dynamically set from the button
    formData.append('comment[body]',commentText ); // This is just a placeholder, replace it with actual body content

    // Send the POST request using Fetch API
    fetch('/resources/comments?via_relation=commentable&via_relation_class=Issue&via_resource_id=' + viaResourceId, {
      method: 'POST',
      headers: {
        'Accept': 'text/vnd.turbo-stream.html, text/html, application/xhtml+xml',
        'Turbo-Frame': 'modal_resource',
      },
      body: formData,
    })
    .then(response => {
      if (response.ok) {

        return response.text(); // Turbo stream responses are returned as HTML
      } else {
        throw new Error('Network response was not ok.');
      }
    })
    .then(data => {
      // Inject the Turbo Stream response into the page
      const turboFrame = document.getElementById('commentable');
      turboFrame.reload()

    })
    .catch(error => {
      console.error('There was a problem with the postComment request:', error);
    });
  }

  cancelComment(event) {
    if (event)
      event.preventDefault();
    this.resetCommentInput(false);
  }

  resetCommentInput(clearText = true) {
    const commentInput = document.getElementById("comment-input");
    const commentInputLabel = document.getElementById("comment-input-label");
    const commentArea = document.getElementById("comment-area");

    commentArea.classList.add("hidden");
    commentInputLabel.classList.add("hidden");
    commentInput.classList.remove("hidden");
    if (clearText)
      this.inlineCommentTextAreaTarget.value = "";
  }
}

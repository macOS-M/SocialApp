import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    document.addEventListener("click", (event) => {
      if (!this.element.contains(event.target)) {
        this.menuTarget?.classList.add("hidden")
      }
    })
  }

  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }
}

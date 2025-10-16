import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["flash"]

  connect() {
    this.flashTargets.forEach((el) => {
      setTimeout(() => this.dismiss(el), 3000)
    })
  }

  dismiss(el) {
    el.style.transition = "opacity 0.5s, max-height 0.5s"
    el.style.opacity = "0"
    el.style.maxHeight = "0px"
    setTimeout(() => el.remove(), 500)
  }
}

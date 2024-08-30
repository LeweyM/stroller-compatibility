import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle-visibility"
export default class extends Controller {
  static targets = ["element"]

  toggle(e) {
    e.preventDefault()
    this.elementTarget.classList.toggle("hidden")
  }
}

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="hide"
export default class extends Controller {
  hide() {
    this.element.style.display = 'none';
  }
}

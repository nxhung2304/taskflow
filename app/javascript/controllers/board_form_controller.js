import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["colorInput", "colorCode"]

  connect() {
    // Called when the controller is connected to the DOM
    console.log("BoardForm controller connected")
  }

  updateColorCode() {
    // Update the color code display when the color input changes
    this.colorCodeTarget.textContent = this.colorInputTarget.value
  }
}

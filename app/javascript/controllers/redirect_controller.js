import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    const frame = this.element;

    frame.addEventListener("turbo:frame-load", () => {
      window.location.href = frame.src;
    });
  }
}

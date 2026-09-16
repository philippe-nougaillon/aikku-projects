import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  connect() {
    if (!window.isSecureContext) {
      console.info("[ServiceWorker] Secure context required; skipping registration.");
      return;
    }

    if ("serviceWorker" in navigator) {
      if (navigator.serviceWorker.controller) {
        // If the service worker is already running, skip to state change
        this.stateChange();
      } else {
        // Register the service worker, and wait for it to become active
        navigator.serviceWorker
          .register("/service-worker.js", { scope: "./" })
          .then((reg) => {
            console.log("[Companion]", "Service worker registered!");
            console.log(reg);
          })
          .catch((error) => {
            console.warn("[Companion] Service worker registration failed:", error);
          });

        navigator.serviceWorker.addEventListener(
          "controllerchange",
          this.controllerChange.bind(this)
        );
      }
    }
  }

  controllerChange(event) {
    if (navigator.serviceWorker.controller) {
      navigator.serviceWorker.controller.addEventListener(
        "statechange",
        this.stateChange.bind(this)
      );
    }
  }

  stateChange() {
    // perform any visual manipulations here
  }
}
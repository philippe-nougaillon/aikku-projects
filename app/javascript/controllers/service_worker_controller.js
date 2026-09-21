import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (!window.isSecureContext) {
      console.info("[ServiceWorker] Secure context required; skipping registration.");
      return;
    }

    if ("serviceWorker" in navigator) {
      navigator.serviceWorker
        .register("/service-worker.js", { scope: "/" })
        .then((reg) => {
          console.log("[ServiceWorker] Registered with scope:", reg.scope);
          // Check for service worker script updates
          reg.update();
        })
        .catch((error) => {
          console.warn("[ServiceWorker] Registration failed:", error);
        });

      navigator.serviceWorker.addEventListener(
        "controllerchange",
        this.controllerChange.bind(this)
      );

      window.addEventListener("online", this.handleOnline.bind(this));
      window.addEventListener("offline", this.handleOffline.bind(this));
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
    // Perform any visual manipulations or cache refreshes here
  }

  handleOnline() {
    console.log("[PWA] Network status: back online");
  }

  handleOffline() {
    console.log("[PWA] Network status: offline");
  }
}
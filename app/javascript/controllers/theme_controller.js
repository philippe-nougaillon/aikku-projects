import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  connect() {
    this.boundOnStorage = this.onStorage.bind(this)
    window.addEventListener("storage", this.boundOnStorage)
    this.syncTheme()
  }

  disconnect() {
    window.removeEventListener("storage", this.boundOnStorage)
  }

  syncTheme() {
    const theme = this.currentTheme
    document.documentElement.setAttribute("data-theme", theme)
    this.highlightActiveTheme(theme)
  }

  get currentTheme() {
    return localStorage.getItem("theme") || document.documentElement.getAttribute("data-theme") || "corporate"
  }

  click(event) {
    const theme = event.currentTarget.dataset.setTheme || event.currentTarget.dataset.themeValue
    if (!theme) return

    localStorage.setItem("theme", theme)
    this.syncTheme()
  }

  select(event) {
    this.click(event)
  }

  highlightActiveTheme(theme) {
    this.itemTargets.forEach((element) => {
      const itemTheme = element.dataset.setTheme || element.dataset.themeValue
      if (itemTheme === theme) {
        element.classList.add("outline", "outline-2", "outline-offset-2")
      } else {
        element.classList.remove("outline", "outline-2", "outline-offset-2")
      }
    })
  }

  onStorage(event) {
    if (event.key === "theme" && event.newValue) {
      this.syncTheme()
    }
  }
}

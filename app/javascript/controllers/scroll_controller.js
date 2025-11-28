import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="scroll"
export default class extends Controller {
  connect() {
    this.scrollToBottom()
  }

  scrollToBottom() {
    this.element.scrollTop = this.element.scrollHeight
  }

  // Cette méthode peut être appelée depuis l'extérieur
  // ou automatiquement quand le contenu change
  onNewMessage() {
    this.scrollToBottom()
  }

  // Observer les changements dans le DOM pour auto-scroll
  initialize() {
    this.observer = new MutationObserver(() => {
      this.scrollToBottom()
    })
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  // Démarrer l'observation quand le controller est connecté
  observe() {
    this.observer.observe(this.element, {
      childList: true,
      subtree: true
    })
  }

  // Appeler observe après la connexion
  connectedCallback() {
    super.connectedCallback?.()
    this.observe()
  }
}

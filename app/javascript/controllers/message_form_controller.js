import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="message-form"
export default class extends Controller {
  static targets = ["content", "messagesContainer"];

  connect() {
    console.log("Message form controller connected");
  }

  // Appelé quand Turbo commence à soumettre le formulaire
  handleSubmitStart(event) {
    console.log("🚀 Soumission commencée");

    const content = this.contentTarget.value.trim();
    if (!content) {
      return;
    }

    // Ajouter immédiatement le message utilisateur
    this.addUserMessage(content);

    // Ajouter le loading
    this.addLoadingMessage();

    // Vider le champ visuellement
    this.contentTarget.value = "";
  }

  // Appelé quand Turbo a reçu la réponse
  handleSubmitEnd(event) {
    console.log("✅ Soumission terminée");
    this.removeLoading();
  }

  addUserMessage(content) {
    const now = new Date();
    const timeString = now.toLocaleString("fr-FR", {
      day: "2-digit",
      month: "2-digit",
      hour: "2-digit",
      minute: "2-digit",
    });

    const messageHtml = `
      <div class="mb-3 text-end">
        <div class="d-inline-block p-3 rounded bg-primary text-white" style="max-width: 75%;">
          <strong>👤 Toi</strong>
          <hr class="my-2">
          <p class="mb-0">${this.escapeHtml(content)}</p>
          <small class="text-muted d-block mt-2" style="font-size: 0.75rem;">
            ${timeString}
          </small>
        </div>
      </div>
    `;

    this.messagesContainerTarget.insertAdjacentHTML("beforeend", messageHtml);
    this.scrollToBottom();
  }

  addLoadingMessage() {
    const loadingHtml = `
      <div class="mb-3 text-start" id="loading-message">
        <div class="d-inline-block p-3 rounded bg-white border" style="max-width: 75%;">
          <strong>🤖 Assistant</strong>
          <hr class="my-2">
          <div class="spinner-border spinner-border-sm" role="status">
            <span class="visually-hidden">Chargement...</span>
          </div>
          <em class="ms-2">Réflexion en cours...</em>
        </div>
      </div>
    `;

    this.messagesContainerTarget.insertAdjacentHTML("beforeend", loadingHtml);
    this.scrollToBottom();
  }

  removeLoading() {
    console.log("🗑️ Suppression du loading");
    const loadingElement = document.getElementById("loading-message");
    if (loadingElement) {
      console.log("✅ Loading supprimé");
      loadingElement.remove();
    } else {
      console.log("⚠️ Loading déjà supprimé");
    }
  }

  scrollToBottom() {
    const container = document.getElementById("messages-container");
    if (container) {
      container.scrollTop = container.scrollHeight;
    }
  }

  escapeHtml(text) {
    const div = document.createElement("div");
    div.textContent = text;
    return div.innerHTML;
  }
}

const API_BASE = import.meta.env.VITE_API_BASE_URL || "http://localhost:4010";
const WHATSAPP = import.meta.env.VITE_WHATSAPP_NUMBER || "923001234567";
const SUPPORT_EMAIL = import.meta.env.VITE_SUPPORT_EMAIL || "support@marqueeflow.com";

function setupNav() {
  const toggle = document.querySelector(".nav-toggle");
  const links = document.querySelector(".nav-links");
  if (!toggle || !links) return;
  toggle.addEventListener("click", () => links.classList.toggle("open"));
  links.querySelectorAll("a").forEach((link) => {
    link.addEventListener("click", () => links.classList.remove("open"));
  });
}

function setupContactLinks() {
  document.querySelectorAll("[data-whatsapp]").forEach((el) => {
    el.href = `https://wa.me/${WHATSAPP}?text=${encodeURIComponent("Hello MarqueeFlow, I would like to know more about your marquee management app.")}`;
    el.target = "_blank";
    el.rel = "noopener noreferrer";
  });
  document.querySelectorAll("[data-email]").forEach((el) => {
    el.href = `mailto:${SUPPORT_EMAIL}`;
  });
}

async function submitDemoForm(form) {
  const statusEl = form.querySelector(".form-status");
  const submitBtn = form.querySelector('button[type="submit"]');
  const payload = Object.fromEntries(new FormData(form).entries());

  statusEl.textContent = "";
  statusEl.className = "form-status";
  submitBtn.disabled = true;
  submitBtn.textContent = "Sending...";

  try {
    const res = await fetch(`${API_BASE}/api/public/demo-request`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });
    const body = await res.json().catch(() => ({}));
    if (!res.ok) {
      throw new Error(body?.error?.message || "Could not submit request. Please try WhatsApp instead.");
    }
    form.reset();
    statusEl.textContent = "Thank you! Our team will contact you shortly.";
    statusEl.className = "form-status form-success";
  } catch (err) {
    statusEl.textContent = err.message || "Something went wrong. Please contact us on WhatsApp.";
    statusEl.className = "form-status form-error";
  } finally {
    submitBtn.disabled = false;
    submitBtn.textContent = "Submit Request";
  }
}

function setupDemoForm() {
  const form = document.getElementById("demo-form");
  if (!form) return;
  form.addEventListener("submit", (event) => {
    event.preventDefault();
    submitDemoForm(form);
  });
}

setupNav();
setupContactLinks();
setupDemoForm();

export { API_BASE, WHATSAPP, SUPPORT_EMAIL };

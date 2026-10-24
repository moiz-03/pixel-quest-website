// main.js — progressive enhancement only. Every page works without this.
// Budget: <= 8 KB unminified / <= 3 KB gzipped.

// --- Mobile nav toggle ----------------------------------------------------
const navToggle = document.querySelector('.nav-toggle');
const navLinks = document.getElementById('nav-links');

if (navToggle && navLinks) {
  const close = () => {
    navLinks.classList.remove('is-open');
    navToggle.setAttribute('aria-expanded', 'false');
  };

  navToggle.addEventListener('click', () => {
    const open = navLinks.classList.toggle('is-open');
    navToggle.setAttribute('aria-expanded', String(open));
  });

  navLinks.addEventListener('click', (e) => {
    if (e.target.closest('a')) close();
  });

  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && navLinks.classList.contains('is-open')) {
      close();
      navToggle.focus();
    }
  });

  document.addEventListener('click', (e) => {
    if (navLinks.classList.contains('is-open') &&
        !navLinks.contains(e.target) &&
        !navToggle.contains(e.target)) {
      close();
    }
  });
}

// --- FAQ accordion --------------------------------------------------------
// Without JS, all <details> stay open (the no-JS fallback).
// With JS, start closed, then open the item named in the URL hash.
document.querySelectorAll('.faq-accordion details[open]').forEach((d) => {
  d.removeAttribute('open');
});

const openFromHash = () => {
  let id = '';
  try { id = decodeURIComponent(location.hash.slice(1)); } catch { return; }
  if (!id) return;
  const el = document.getElementById(id);
  if (el && el.matches('.faq-accordion details')) {
    el.open = true;
    el.scrollIntoView({ block: 'start' });
  }
};
openFromHash();
window.addEventListener('hashchange', openFromHash);

// Close open FAQ accordion item on Escape key press
document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') {
    const openDetails = document.querySelectorAll('.faq-accordion details[open]');
    openDetails.forEach((detail) => {
      detail.removeAttribute('open');
      detail.querySelector('summary')?.focus();
    });
  }
});
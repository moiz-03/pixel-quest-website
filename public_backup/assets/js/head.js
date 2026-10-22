// Blocking, single-purpose: mark the document as JS-enabled before first
// paint so the mobile nav can show its hamburger without a flash.
document.documentElement.classList.add('js');
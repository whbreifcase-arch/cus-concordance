/* CUS — shared page behaviour. Theme selector only.
   Uses the SAME localStorage key as HOW_TO_PLAY_v1_5.html, so a reader's
   light/dark choice follows them across every page in play/. */
(function () {
  'use strict';
  var KEY = 'cus-how-to-play-theme';
  var buttons = [].slice.call(document.querySelectorAll('[data-set-theme]'));

  function setTheme(theme, persist) {
    var next = theme === 'light' ? 'light' : 'dark';
    document.documentElement.dataset.theme = next;
    buttons.forEach(function (b) {
      b.setAttribute('aria-pressed', String(b.dataset.setTheme === next));
    });
    if (persist !== false) { try { localStorage.setItem(KEY, next); } catch (e) {} }
  }

  buttons.forEach(function (b) {
    b.addEventListener('click', function () { setTheme(b.dataset.setTheme); });
  });

  var saved = 'dark';
  try { saved = localStorage.getItem(KEY) || 'dark'; } catch (e) {}
  setTheme(saved, false);
})();

// Kairos: comportamiento de las páginas (sin enrutador por hash).
// - Contador del carrito guardado en el navegador.
// - Filtros del catálogo.
// - Galería de fotos en la página de cada producto.
(function () {
  "use strict";

  var CART_KEY = "kairos-cart";

  function readCart() {
    try { return JSON.parse(localStorage.getItem(CART_KEY) || "[]"); } catch (e) { return []; }
  }
  function writeCart(items) {
    try { localStorage.setItem(CART_KEY, JSON.stringify(items)); } catch (e) { /* almacenamiento no disponible */ }
  }

  function updateCartCount() {
    var el = document.getElementById("cart-count");
    if (el) el.textContent = readCart().length;
  }

  var toastTimer;
  function toast(msg) {
    var t = document.getElementById("toast");
    if (!t) return;
    t.textContent = msg;
    t.classList.add("show");
    clearTimeout(toastTimer);
    toastTimer = setTimeout(function () { t.classList.remove("show"); }, 2200);
  }

  // Agregar al carrito
  document.addEventListener("click", function (e) {
    var add = e.target.closest("[data-add]");
    if (!add) return;
    var items = readCart();
    items.push(add.getAttribute("data-add"));
    writeCart(items);
    updateCartCount();
    toast((add.getAttribute("data-name") || "Producto") + " agregado al carrito");
  });

  // Filtros del catálogo
  var filters = document.getElementById("filters");
  if (filters) {
    var grid = document.getElementById("grid");
    var count = document.getElementById("count");
    var cards = Array.prototype.slice.call(grid.querySelectorAll(".product"));
    filters.addEventListener("click", function (e) {
      var btn = e.target.closest("button[data-filter]");
      if (!btn) return;
      var f = btn.getAttribute("data-filter");
      Array.prototype.forEach.call(filters.querySelectorAll("button"), function (b) {
        b.classList.toggle("active", b === btn);
      });
      var shown = 0;
      cards.forEach(function (c) {
        var visible = f === "todos" || c.getAttribute("data-cat") === f;
        c.hidden = !visible;
        if (visible) shown++;
      });
      if (count) count.textContent = "Mostrando " + shown + " de " + cards.length + " productos";
    });
  }

  // Galería de la página de producto
  var thumbs = document.getElementById("thumbs");
  if (thumbs) {
    thumbs.addEventListener("click", function (e) {
      var btn = e.target.closest("button[data-index]");
      if (!btn) return;
      var main = document.getElementById("main-img");
      var img = btn.querySelector("img");
      if (main && img) main.src = img.getAttribute("src");
      Array.prototype.forEach.call(thumbs.querySelectorAll("button"), function (b) {
        b.setAttribute("aria-current", String(b === btn));
      });
    });
  }

  // Lista del carrito
  var list = document.getElementById("cart-list");
  if (list) {
    var items = readCart();
    var summary = document.getElementById("cart-summary");
    if (items.length && summary) {
      summary.textContent = "Tienes " + items.length + (items.length === 1 ? " producto" : " productos") + " en tu carrito:";
      var counts = {};
      items.forEach(function (id) { counts[id] = (counts[id] || 0) + 1; });
      Object.keys(counts).forEach(function (id) {
        var li = document.createElement("li");
        li.textContent = id + " × " + counts[id];
        list.appendChild(li);
      });
    }
  }

  updateCartCount();
})();

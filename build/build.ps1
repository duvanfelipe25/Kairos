# Genera todas las páginas de Kairos Tecnology a partir de data\productos.json.
# Uso (en PowerShell, desde la carpeta Kairo):  powershell -ExecutionPolicy Bypass -File build\build.ps1

$ErrorActionPreference = 'Stop'
$Site = Split-Path -Parent $PSScriptRoot

# ---- Configuración: cambia estos valores ----
$SiteUrl = 'https://duvanfelipe25.github.io/Kairos'   # enlace final de la página, sin barra al final
$Email   = 'kairos.tecnology.tienda@gmail.com'            # correo de contacto real
$Legal   = '[NOMBRE LEGAL DE LA EMPRESA]'      # razón social, NIT y dirección cuando estén listos
# ----------------------------------------------

$products = Get-Content -Raw -Encoding UTF8 (Join-Path $Site 'data\productos.json') | ConvertFrom-Json

function E([string]$t) { [System.Net.WebUtility]::HtmlEncode($t) }
function Money([double]$v) { ([string]::Format([Globalization.CultureInfo]::InvariantCulture, '{0:N0}', $v)).Replace(',', '.') }
function Write-Page([string]$relPath, [string]$html) {
  $full = Join-Path $Site $relPath
  $dir = Split-Path -Parent $full
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
  [System.IO.File]::WriteAllText($full, $html, (New-Object System.Text.UTF8Encoding($false)))
}

function Get-Head([string]$title, [string]$desc, [string]$rel, [string]$canon, [string]$extra = '') {
@"
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$(E $title)</title>
  <meta name="description" content="$(E $desc)">
  <meta name="robots" content="index,follow">
  <link rel="canonical" href="$SiteUrl/$canon">
  <meta property="og:title" content="$(E $title)">
  <meta property="og:description" content="$(E $desc)">
  <meta property="og:type" content="website">
  <meta property="og:locale" content="es_CO">
  <link rel="icon" href="$($rel)logo.svg">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Oswald:wght@500;600;700&family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="$($rel)css/styles.css">
$extra
</head>
<body>
  <a class="skip" href="#contenido">Ir al contenido</a>
"@
}

function Get-Header([string]$rel, [string]$active) {
  $nav = @(
    @{ key = 'productos'; href = 'productos.html'; label = 'Explorar productos' },
    @{ key = 'nosotros';  href = 'nosotros.html';  label = 'Nosotros' },
    @{ key = 'contacto';  href = 'contacto.html';  label = 'Contacto' }
  ) | ForEach-Object {
    $cls = if ($_.key -eq $active) { 'pill active' } else { 'pill' }
    "        <a class=""$cls"" href=""$rel$($_.href)"">$($_.label)</a>"
  }
@"
  <header>
    <div class="nav">
      <a class="brand" href="$($rel)index.html">
        <img src="$($rel)logo.svg" alt="Logo Kairos Tecnology" width="40" height="40">
        KAIROS TECNOLOGY
      </a>
      <nav class="pills" aria-label="Principal">
$($nav -join "`n")
        <a class="pill cart-pill" href="$($rel)carrito.html" aria-label="Carrito">Carrito <span class="cart-count" id="cart-count">0</span></a>
      </nav>
    </div>
  </header>

"@
}

function Get-Footer([string]$rel) {
@"
  <footer>
    <div class="foot-cols">
      <div><strong>Kairos Tecnology</strong><br>Accesorios de tecnología · Bogotá, Colombia</div>
      <div>Correo: $(E $Email)<br>Instagram · TikTok · Facebook</div>
      <div><a href="$($rel)terminos.html">Términos y condiciones</a><br><a href="$($rel)privacidad.html">Política de privacidad</a></div>
    </div>
    <p class="foot-legal">© 2026 Kairos Tecnology. Todos los derechos reservados.</p>
  </footer>
  <div class="toast" id="toast" role="status" aria-live="polite"></div>
  <script src="$($rel)js/app.js"></script>
</body>
</html>
"@
}

# ---------- Página de inicio ----------
$pageHome = (Get-Head 'Kairos Tecnology | Accesorios de tecnología en Colombia' 'Audífonos, parlantes, diademas y accesorios para tu celular y tu computador. Envíos a todo Colombia.' '' 'index.html') +
  (Get-Header '' '') + @"
  <main id="contenido">
    <section class="intro">
      <h1>Tu tecnología, <span>con confianza</span></h1>
      <p>Audífonos, parlantes y accesorios para tus dispositivos. Envíos a todo Colombia.</p>
      <a class="cta" href="productos.html">Ver productos</a>
    </section>
    <section class="perks">
      <div class="perk"><strong>Envíos a todo el país</strong><span>Llegamos a donde estés.</span></div>
      <div class="perk"><strong>Calidad verificada</strong><span>Solo vendemos lo que usaríamos nosotros.</span></div>
      <div class="perk"><strong>Atención cercana</strong><span>Te respondemos rápido y hablamos claro.</span></div>
    </section>
    <section class="slogan"><p>Conéctate <span>con confianza</span></p></section>
  </main>

"@ + (Get-Footer '')
Write-Page 'index.html' $pageHome

# ---------- Catálogo ----------
$cards = foreach ($p in $products) {
@"
      <article class="product" data-cat="$($p.category)">
        <a class="thumb" href="productos/$($p.id).html" aria-label="Ver $(E $p.name)"><img src="img/$($p.images[0])" alt="$(E $p.imageAlt)" loading="lazy" width="600" height="600"></a>
        <div class="tag">$(E $p.categoryLabel)</div>
        <h2 class="card-title"><a href="productos/$($p.id).html">$(E $p.name)</a></h2>
        <p>$(E $p.shortDesc)</p>
        <div class="price">$(Money $p.price)<small>COP</small></div>
        <div class="meta">Envío a todo Colombia</div>
        <a class="btn-link" href="productos/$($p.id).html">Ver detalle</a>
        <button class="btn-add" data-add="$($p.id)" data-name="$(E $p.name)" type="button">Agregar</button>
      </article>
"@
}
$catalog = (Get-Head 'Productos de audio y accesorios | Kairos Tecnology' 'Catálogo de Kairos Tecnology: diademas, parlantes portátiles y mousepad gaming con envío a todo Colombia.' '' 'productos.html') +
  (Get-Header '' 'productos') + @"
  <main id="contenido" class="view">
    <h1 class="view-title">Nuestros productos</h1>
    <p class="lead">Audio y accesorios para tu celular, tu computador y tu día a día.</p>
    <div class="filters" id="filters" role="group" aria-label="Filtrar por categoría">
      <button class="pill active" data-filter="todos" type="button">Todos</button>
      <button class="pill" data-filter="audio" type="button">Audio</button>
      <button class="pill" data-filter="accesorios" type="button">Accesorios</button>
    </div>
    <span class="count" id="count">Mostrando $($products.Count) de $($products.Count) productos</span>
    <div class="grid" id="grid">
$($cards -join "`n")
    </div>
  </main>

"@ + (Get-Footer '')
Write-Page 'productos.html' $catalog

# ---------- Página de cada producto ----------
foreach ($p in $products) {
  $thumbs = for ($i = 0; $i -lt $p.images.Count; $i++) {
    $cur = if ($i -eq 0) { 'true' } else { 'false' }
    "        <button type=""button"" data-index=""$i"" aria-current=""$cur"" aria-label=""Foto $($i + 1)""><img src=""../img/$($p.images[$i])"" alt="""" width=""100"" height=""100""></button>"
  }
  $specs = foreach ($s in $p.specs) { "        <div><dt>$(E $s[0])</dt><dd>$(E $s[1])</dd></div>" }
  $desc = "$($p.name): $($p.shortDesc) Envío a todo Colombia."
  $ld = @"
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "Product",
    "name": "$(E $p.name)",
    "image": "$SiteUrl/img/$($p.images[0])",
    "description": "$(E $p.longDesc)",
    "brand": { "@type": "Brand", "name": "Kairos Tecnology" },
    "offers": { "@type": "Offer", "priceCurrency": "COP", "price": "$($p.price)", "availability": "https://schema.org/InStock", "url": "$SiteUrl/productos/$($p.id).html" }
  }
  </script>
"@
  $page = (Get-Head "$($p.name) | Kairos Tecnology" $desc '../' "productos/$($p.id).html" $ld) +
    (Get-Header '../' 'productos') + @"
  <main id="contenido" class="view">
    <nav class="crumbs" aria-label="Ruta"><a href="../index.html">Inicio</a> / <a href="../productos.html">Productos</a> / <span>$(E $p.name)</span></nav>
    <div class="detail">
      <div class="gallery">
        <div class="main-photo"><img id="main-img" src="../img/$($p.images[0])" alt="$(E $p.imageAlt)" width="800" height="800"></div>
        <div class="thumbs" id="thumbs">
$($thumbs -join "`n")
        </div>
      </div>
      <div class="info-panel">
        <div class="tag">$(E $p.categoryLabel)</div>
        <h1>$(E $p.name)</h1>
        <p class="desc">$(E $p.longDesc)</p>
        <div class="price">$(Money $p.price)<small>COP</small></div>
        <dl class="specs">
$($specs -join "`n")
        </dl>
        <div class="buy-row">
          <button class="btn-add" data-add="$($p.id)" data-name="$(E $p.name)" type="button">Agregar al carrito</button>
          <a class="btn-link" href="../productos.html">Seguir comprando</a>
        </div>
      </div>
    </div>
  </main>

"@ + (Get-Footer '../')
  Write-Page "productos/$($p.id).html" $page
}

# ---------- Nosotros ----------
$nosotros = (Get-Head 'Quiénes somos | Kairos Tecnology' 'Conoce la misión, la visión y los valores de Kairos Tecnology, tienda de accesorios de tecnología en Colombia.' '' 'nosotros.html') +
  (Get-Header '' 'nosotros') + @"
  <main id="contenido" class="view">
    <h1 class="view-title">Quiénes somos</h1>
    <p class="lead">Kairos Tecnology nace para que comprar accesorios tecnológicos sea fácil, seguro y cercano.</p>
    <div class="about">
      <section class="info-card"><h2>Misión</h2><p>Ofrecer accesorios de tecnología de buena calidad a precios justos, con envíos a todo Colombia y una atención cercana que haga de cada compra una decisión confiable.</p></section>
      <section class="info-card"><h2>Visión</h2><p>Ser la tienda de accesorios tecnológicos más confiable de Colombia en 2031, reconocida por su calidad, su servicio y su presencia digital en español e inglés.</p></section>
    </div>
    <h2 class="section-title">Valores</h2>
    <div class="values">
      <div class="info-card"><h3>Confianza</h3><p>Lo que prometemos, lo cumplimos.</p></div>
      <div class="info-card"><h3>Calidad</h3><p>Solo vendemos lo que usaríamos nosotros.</p></div>
      <div class="info-card"><h3>Cercanía</h3><p>Respondemos rápido y hablamos claro.</p></div>
    </div>
  </main>

"@ + (Get-Footer '')
Write-Page 'nosotros.html' $nosotros

# ---------- Contacto ----------
$contacto = (Get-Head 'Contacto | Kairos Tecnology' 'Escríbenos a Kairos Tecnology. Envíos a todo Colombia desde Bogotá.' '' 'contacto.html') +
  (Get-Header '' 'contacto') + @"
  <main id="contenido" class="view">
    <h1 class="view-title">Contacto</h1>
    <p class="lead">Escríbenos y te respondemos lo antes posible.</p>
    <div class="about">
      <section class="info-card"><h2>Ciudad</h2><p>Bogotá, Colombia. Envíos a todo el país.</p></section>
      <section class="info-card"><h2>Correo</h2><p>$(E $Email)</p></section>
      <section class="info-card"><h2>Redes</h2><p>Instagram · TikTok · Facebook</p></section>
    </div>
  </main>

"@ + (Get-Footer '')
Write-Page 'contacto.html' $contacto

# ---------- Carrito (contador simple) ----------
$carrito = (Get-Head 'Carrito | Kairos Tecnology' 'Tu carrito de compras en Kairos Tecnology.' '' 'carrito.html') +
  (Get-Header '' '') + @"
  <main id="contenido" class="view">
    <h1 class="view-title">Tu carrito</h1>
    <div class="info-card">
      <p id="cart-summary">Todavía no tienes productos.</p>
      <ul class="cart-list" id="cart-list"></ul>
      <p class="lead">Para completar tu pedido escríbenos a $(E $Email). Puedes pagar por transferencia, con pasarela de pago en línea o contra entrega si estás en Bogotá.</p>
      <a class="btn-link" href="productos.html">Seguir comprando</a>
    </div>
  </main>

"@ + (Get-Footer '')
Write-Page 'carrito.html' $carrito

# ---------- Términos y privacidad (borradores) ----------
$terminos = (Get-Head 'Términos y condiciones | Kairos Tecnology' 'Términos y condiciones de compra en Kairos Tecnology.' '' 'terminos.html') +
  (Get-Header '' '') + @"
  <main id="contenido" class="view prose">
    <h1 class="view-title">Términos y condiciones</h1>
    <p><em>Borrador. Debe revisarlo un abogado antes de publicarse.</em></p>
    <h2>1. Responsable</h2><p>$(E $Legal) es el responsable de esta tienda en línea. Contacto: $(E $Email).</p>
    <h2>2. Productos y precios</h2><p>Los precios se muestran en pesos colombianos e incluyen los impuestos que apliquen. Las características de los productos corresponden a la ficha técnica del fabricante.</p>
    <h2>3. Pedidos y pagos</h2><p>Los pedidos se confirman por WhatsApp o correo electrónico. Aceptamos pago por transferencia, pasarela de pago en línea (cuando esté activa) y pago contra entrega, este último solo para entregas en Bogotá.</p>
    <h2>4. Envíos</h2><p>Hacemos envíos a todo Colombia. [Indicar tiempos y costos de envío.]</p>
    <h2>5. Devoluciones y garantía</h2><p>[Indicar el plazo para devolución y la garantía legal aplicable.]</p>
    <h2>6. Ley aplicable</h2><p>Estos términos se rigen por la legislación colombiana.</p>
  </main>

"@ + (Get-Footer '')
Write-Page 'terminos.html' $terminos

$privacidad = (Get-Head 'Política de privacidad | Kairos Tecnology' 'Cómo Kairos Tecnology trata tus datos personales.' '' 'privacidad.html') +
  (Get-Header '' '') + @"
  <main id="contenido" class="view prose">
    <h1 class="view-title">Política de privacidad</h1>
    <p><em>Borrador. Debe revisarlo un abogado antes de publicarse.</em></p>
    <h2>1. Responsable del tratamiento</h2><p>$(E $Legal). Correo: $(E $Email).</p>
    <h2>2. Datos que recogemos</h2><p>[Listar los datos que se piden en la tienda: nombre, correo, dirección, teléfono.]</p>
    <h2>3. Finalidad</h2><p>Usamos tus datos para procesar pedidos, enviar tu compra y responder tus solicitudes.</p>
    <h2>4. Tus derechos</h2><p>Puedes conocer, actualizar, rectificar o suprimir tus datos escribiendo a $(E $Email), según la Ley 1581 de 2012.</p>
    <h2>5. Base de datos</h2><p>[Indicar si la base de datos está inscrita en el Registro Nacional de Bases de Datos de la SIC.]</p>
  </main>

"@ + (Get-Footer '')
Write-Page 'privacidad.html' $privacidad

# ---------- SEO: robots.txt y sitemap.xml ----------
$pages = @('index.html','productos.html','nosotros.html','contacto.html','terminos.html','privacidad.html') + ($products | ForEach-Object { "productos/$($_.id).html" })
$urls = $pages | ForEach-Object { "  <url><loc>$SiteUrl/$_</loc></url>" }
$sitemap = "<?xml version=""1.0"" encoding=""UTF-8""?>`n<urlset xmlns=""http://www.sitemaps.org/schemas/sitemap/0.9"">`n$($urls -join "`n")`n</urlset>`n"
Write-Page 'sitemap.xml' $sitemap
Write-Page 'robots.txt' "User-agent: *`nAllow: /`n`nSitemap: $SiteUrl/sitemap.xml`n"

Write-Output "Listo: $($pages.Count) páginas generadas en $Site"

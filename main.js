import './style.css';

document.querySelector('#app').innerHTML = `
  <div class="landing-container">
    <header class="hero">
      <div class="badge">Innovación Tecnológica</div>
      <h1>Infraestructura resiliente</h1>
      <p class="subtitle">Diseño colaborativo con <span class="highlight-k8s">Kubernetes</span> y <span class="highlight-docker">Docker</span></p>
    </header>
    
    <main>
      <div class="cards-container">
        <div class="card card-docker">
          <div class="card-icon">🐳</div>
          <h2>Docker</h2>
          <p>Empaquetamiento, contenedorización y portabilidad absoluta para tus aplicaciones desde el desarrollo hasta producción.</p>
        </div>
        
        <div class="card card-kubernetes">
          <div class="card-icon">☸️</div>
          <h2>Kubernetes</h2>
          <p>Orquestación avanzada, escalabilidad automática y alta disponibilidad para entornos resistentes a fallos.</p>
        </div>
      </div>
    </main>

    <div class="background-glow blur-k8s"></div>
    <div class="background-glow blur-docker"></div>
  </div>
`;

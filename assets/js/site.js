// /public/site.js
(() => {
  const state = {
    audioEnabled: false,
    assets: null, // loaded asset_index.json
    bg: null, // current background URL
    sfx: {}, // HTMLAudioElements
  };

  // ---- SFX registry (drop your file names after renaming below) ----
  const SFX_FILES = {
    click: "/public/sfx/sfx-click.mp3",
    glitch: "/public/sfx/sfx-glitch.mp3",
    portalOpen: "/public/sfx/sfx-magic-portal.mp3",
    treasureOpen: "/public/sfx/sfx-chest-open.mp3",
    laser: "/public/sfx/sfx-laser.mp3",
    splash: "/public/sfx/sfx-splash.mp3",
    explosion: "/public/sfx/sfx-big-explosion.mp3",
  };

  // ---- Audio gesture gate ----
  function enableAudioOnce() {
    if (state.audioEnabled) return;
    Object.entries(SFX_FILES).forEach(([key, url]) => {
      const a = new Audio(url);
      a.preload = "auto";
      state.sfx[key] = a;
    });
    state.audioEnabled = true;
    document.getElementById("enable-audio").disabled = true;
  }

  function playSfx(name) {
    if (!state.audioEnabled) return;
    const a = state.sfx[name];
    if (a) {
      a.currentTime = 0;
      a.play().catch(() => {});
    }
  }

  // ---- Load asset index & build gallery ----
  async function loadAssets() {
    const res = await fetch("/public/data/asset_index.json", {
      cache: "no-store",
    });
    state.assets = await res.json();
    buildBackgroundGallery(state.assets.backgrounds || []);
  }

  function buildBackgroundGallery(bgs) {
    const wrap = document.getElementById("gallery");
    wrap.innerHTML = "";
    bgs.forEach((src) => {
      const img = document.createElement("img");
      img.src = src;
      img.alt = "";
      img.className = "bg-thumb";
      img.addEventListener("click", () => setBackground(src));
      wrap.appendChild(img);
    });
  }

  function setBackground(url) {
    state.bg = url;
    const stage = document.getElementById("stage");
    stage.style.backgroundImage = `url("${url}")`;
    playSfx("portalOpen");
    document.getElementById("gallery").hidden = true;
  }

  // ---- UI wires ----
  window.addEventListener("pointerdown", enableAudioOnce, { once: true });
  document
    .getElementById("enable-audio")
    .addEventListener("click", enableAudioOnce);
  document.getElementById("show-gallery").addEventListener("click", () => {
    const g = document.getElementById("gallery");
    g.hidden = !g.hidden;
  });

  // Example stage interactions:
  document
    .getElementById("stage")
    .addEventListener("click", () => playSfx("click"));
  document.addEventListener("keydown", (e) => {
    if (e.key === "g") playSfx("glitch");
    if (e.key === "l") playSfx("laser");
    if (e.key === "x") playSfx("explosion");
  });

  loadAssets();
})();

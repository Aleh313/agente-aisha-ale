// ============================================================================
// EXTENSIÓN DE AISHA GREYRAT PARA BRAVE (CONTROL DE PESTAÑA ÚNICA YOUTUBE MUSIC)
// ============================================================================
let ws = null;

function connectToElectronicat() {
  try {
    ws = new WebSocket('ws://localhost:3000');

    ws.onopen = () => {
      console.log('🧹 Aisha YT Music Bridge conectado a Oficina Electronicat');
      ws.send(JSON.stringify({ type: 'register_ytm_extension' }));
    };

    ws.onmessage = async (event) => {
      try {
        const msg = JSON.parse(event.data);
        if (msg.type === 'ytm_ext_command') {
          await handleYTMCommand(msg.action, msg.url, msg.query);
        }
      } catch (e) {}
    };

    ws.onclose = () => setTimeout(connectToElectronicat, 2000);
    ws.onerror = () => { try { ws.close(); } catch (e) {} };
  } catch (e) {
    setTimeout(connectToElectronicat, 2000);
  }
}

async function getSingleYTMTab() {
  const tabs = await chrome.tabs.query({ url: '*://music.youtube.com/*' });
  if (tabs.length === 0) return null;
  // Si había pestañas viejas abiertas de antes, cerrar todas las sobrantes automáticamente y dejar SOLO UNA
  if (tabs.length > 1) {
    const toClose = tabs.slice(1).map(t => t.id);
    try { await chrome.tabs.remove(toClose); } catch (e) {}
  }
  return tabs[0];
}

async function handleYTMCommand(action, targetUrl, query) {
  let tab = await getSingleYTMTab();

  if (action === 'open_ytm' || action === 'search_ytm') {
    const finalUrl = targetUrl || 'https://music.youtube.com/';
    if (tab) {
      // Reutilizar la MISMA pestaña siempre (Cero pestañas nuevas)
      await chrome.tabs.update(tab.id, { url: finalUrl, active: true });
    } else {
      await chrome.tabs.create({ url: finalUrl, active: true });
    }
    return;
  }

  if (!tab) return;

  // Ejecutar Play/Pausa, Siguiente, Anterior directo adentro del reproductor de esa única pestaña
  await chrome.scripting.executeScript({
    target: { tabId: tab.id },
    func: (act) => {
      const playBtn = document.querySelector('#play-pause-button') || document.querySelector('.play-pause-button');
      const nextBtn = document.querySelector('.next-button');
      const prevBtn = document.querySelector('.previous-button');
      const video = document.querySelector('video');

      if (act === 'playpause') {
        if (playBtn) playBtn.click();
        else if (video) video.paused ? video.play() : video.pause();
      } else if (act === 'next') {
        if (nextBtn) nextBtn.click();
      } else if (act === 'prev') {
        if (prevBtn) prevBtn.click();
      }
    },
    args: [action]
  });
}

connectToElectronicat();

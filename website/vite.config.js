import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// The Flutter web build lives in public/play (see scripts/copy-play.mjs).
// Static hosts serve /play/ as public/play/index.html, but Vite's dev and
// preview servers would fall back to the site's own index.html: point them
// at the game's index instead.
function servePlay() {
  const rewrite = (req, _res, next) => {
    if (req.url === '/play' || req.url === '/play/') req.url = '/play/index.html'
    next()
  }
  return {
    name: 'serve-play',
    configureServer: (server) => { server.middlewares.use(rewrite) },
    configurePreviewServer: (server) => { server.middlewares.use(rewrite) },
  }
}

// https://vite.dev/config/
export default defineConfig({
  plugins: [servePlay(), react()],
})

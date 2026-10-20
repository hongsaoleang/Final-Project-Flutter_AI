import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'
import os from 'os'

function getLanIp() {
  const nets = os.networkInterfaces()
  // Look for primary physical Wi-Fi/Ethernet IPv4
  for (const name of Object.keys(nets)) {
    for (const net of nets[name]) {
      if (net.family === 'IPv4' && !net.internal) {
        if (!net.address.startsWith('172.') && !net.address.startsWith('192.168.10.') && !net.address.startsWith('192.168.25')) {
          return net.address
        }
      }
    }
  }
  for (const name of Object.keys(nets)) {
    for (const net of nets[name]) {
      if (net.family === 'IPv4' && !net.internal) {
        return net.address
      }
    }
  }
  return '192.168.100.219'
}

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  define: {
    __DETECTED_LAN_IP__: JSON.stringify(getLanIp()),
  },
  server: {
    host: true, // Listen on all network interfaces (0.0.0.0)
    port: 5173,
  },
})

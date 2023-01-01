import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';

// https://vitejs.dev/config/
export default (({mode}) => {

  //https://vitejs.dev/guide/api-javascript.html#loadenv
  process.env = {...process.env, ...loadEnv(mode, './config/env', '')};

  return defineConfig({
    plugins: [react()],
    server: {
      host: '0.0.0.0',
      port: process.env.VITE_APP_PORT
    }
  });
});

/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_API_BASE_URL?: string; // = "http://98.90.107.205:8000";
  readonly VITE_APP_NAME?: string = "Firefighter Safety Data Hub"
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}

/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_API_BASE_URL?: string; // = "https://api.smokeread.com";
  readonly VITE_APP_NAME?: string = "Firefighter Safety Data Hub"
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}

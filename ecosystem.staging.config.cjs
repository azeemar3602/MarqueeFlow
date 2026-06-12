/** Staging PM2 config — separate process/port from production. Do not modify AluRate processes. */
module.exports = {
  apps: [
    {
      name: "marqueeflow-backend-staging",
      cwd: "/var/www/marqueeflow-staging/backend",
      script: "src/server.js",
      instances: 1,
      autorestart: true,
      max_memory_restart: "300M",
      env: {
        NODE_ENV: "staging",
        PORT: 4012,
        HOST: "127.0.0.1",
        ADMIN_ORIGIN: "https://admin-staging.marqueeflow.com"
      },
      error_file: "/var/log/marqueeflow/staging-backend-error.log",
      out_file: "/var/log/marqueeflow/staging-backend-out.log"
    }
  ]
};

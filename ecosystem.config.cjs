module.exports = {
  apps: [
    {
      name: "marqueeflow-backend",
      cwd: "/var/www/marqueeflow/backend",
      script: "src/server.js",
      instances: 1,
      autorestart: true,
      max_memory_restart: "300M",
      env: {
        NODE_ENV: "production",
        PORT: 4010,
        HOST: "127.0.0.1"
      },
      error_file: "/var/log/marqueeflow/backend-error.log",
      out_file: "/var/log/marqueeflow/backend-out.log"
    },
    {
      name: "marqueeflow-admin",
      cwd: "/var/www/marqueeflow/admin-panel",
      script: "npm",
      args: "run start",
      instances: 1,
      autorestart: true,
      max_memory_restart: "200M",
      env: {
        NODE_ENV: "production"
      },
      error_file: "/var/log/marqueeflow/admin-error.log",
      out_file: "/var/log/marqueeflow/admin-out.log"
    }
  ]
};

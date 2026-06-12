# MarqueeFlow deployment

## VPS (isolated)

- Path: `/var/www/marqueeflow`
- PM2: `marqueeflow-backend`, `marqueeflow-admin`
- Ports: `4010` (API), `4011` (admin preview)
- Logs: `/var/log/marqueeflow/`
- Nginx: new files only under `/etc/nginx/sites-available/`

## DNS (marqueeflow.com)

| Host | Type | Value |
|------|------|-------|
| `@` | A | `187.77.86.114` |
| `www` | A | `187.77.86.114` |
| `api` | A | `187.77.86.114` |
| `admin` | A | `187.77.86.114` |

## SSL

```bash
sudo certbot --nginx -d marqueeflow.com -d www.marqueeflow.com -d api.marqueeflow.com -d admin.marqueeflow.com
sudo nginx -t && sudo systemctl reload nginx
```

## GitHub Secrets

- `VPS_SSH_HOST` = `187.77.86.114`
- `VPS_SSH_USER` = `root`
- `VPS_SSH_PRIVATE_KEY` = deploy key private key
- `VPS_SSH_PORT` = `22`
- `MARQUEEFLOW_JWT_SECRET`
- `MARQUEEFLOW_DB_PASSWORD`

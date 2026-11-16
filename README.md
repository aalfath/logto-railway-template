# Logto on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/logto-2?utm_medium=integration&utm_source=button&utm_campaign=logto)

This repo is the source of the **Logto** template on Railway. It deploys [Logto](https://github.com/logto-io/logto) **1.46.0**, an open-source identity and access platform (OIDC, OAuth 2.1, SAML SSO, RBAC, MFA, organizations).

## What the template deploys

| Service | Built from | Purpose |
|---|---|---|
| **Logto** | `logto/` (`svhd/logto:1.46.0`, pinned by digest) | Logto core: the OIDC provider, sign-in pages and Management API on port 3001, with its own public domain. Also serves the admin console on port 3002 over the private network |
| **Logto Console** | `console/` (`caddy:2.11.9-alpine`, pinned by digest) | A small Caddy proxy that puts Logto's admin console (port 3002) on its own public domain |
| **Postgres** | Railway's Postgres | All Logto data: users, applications, keys, settings |

On every start, the Logto service seeds the database if it's empty (`logto db seed --swe`) and applies the schema alterations for its version (`logto db alteration deploy latest`), so an update needs no manual migration step.

## Variables

| Service | Variable | Value | Notes |
|---|---|---|---|
| Logto | `PORT` | `3001` | Port of Logto core (public domain and health check) |
| Logto | `DB_URL` | `${{Postgres.DATABASE_URL}}` | Postgres connection string |
| Logto | `ENDPOINT` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | Public URL of Logto core, used as the OIDC issuer. Change it if you add a custom domain |
| Logto | `ADMIN_ENDPOINT` | `https://${{Logto Console.RAILWAY_PUBLIC_DOMAIN}}` | Public URL of the admin console |
| Logto Console | `PORT` | `8080` | Port Caddy listens on |
| Logto Console | `LOGTO_ADMIN_UPSTREAM` | `${{Logto.RAILWAY_PRIVATE_DOMAIN}}:3002` | Logto's admin port on the private network |

The deploy asks for nothing. Logto generates its signing keys and cookie secrets in the database on the first boot.

## After deploying

Open the **Logto Console** URL right away and create the first account: it becomes the admin. Then set up your applications, sign-in experience and connectors (email, SMS, social) in the console. Your apps sign in against the **Logto** URL.

Health checks: Logto `/oidc/.well-known/openid-configuration`, Logto Console `/healthz`.

## Updates

The template builds from this repo's `main` branch. When a new Logto version is merged here (pin bump plus a `CHANGELOG.md` entry), Railway shows deployers an "update available" notice, and they choose when to apply it. Read [CHANGELOG.md](CHANGELOG.md) and Logto's [release notes](https://github.com/logto-io/logto/releases) before you update, and back up Postgres first: database alterations run on start and aren't reversed automatically.

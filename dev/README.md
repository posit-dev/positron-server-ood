# Local validation environment

This directory starts Open OnDemand (OOD) and a two-node Slurm cluster in
Docker, with the Positron app from the repository root installed. Use it to
launch a Positron session in a browser before you deploy the app to a real
cluster.

## Requirements

- Docker with Compose v2, and about 25 GB of free disk space.
- Ports 3443, 5554, and 6222 free on `127.0.0.1`.
- Internet access for the first start. Docker pulls about 22 GB of images,
  and the installer downloads the 650 MB Positron Server archive.

## Secrets

The `secrets/` directory is ignored by git. Put these files in it before the
first start:

| File | Required | Purpose |
|---|---|---|
| `license.lic` | yes, for a working session | The Positron Server license file from Posit. The installer copies it into the activation directory of the install. Without it, every session stops with **No license key provided**, which is useful for testing the troubleshooting page and nothing else. |
| `signing-key.pem` | no | A private key that matches the public key embedded in the Positron Server build. When present and `license.lic` is absent, the dev wrapper mints a signed per-session license key, which exercises the `--license-key-file` path. Release builds embed a production key, so this only works with builds that embed the development key. |

## Start

```bash
cd dev
docker compose up -d
```

The first start builds the compute image, which compiles Slurm, and runs the
`installer` service, which downloads Positron Server into a shared volume. Both
take several minutes. Watch with `docker compose logs -f installer cpn01`.

The cluster is ready when `sinfo` shows both nodes idle:

```bash
docker compose exec frontend sinfo
```

Then open <https://localhost:3443/>, accept the self-signed certificate, and
sign in as `hpcadmin` with password `ilovelinux`. Open **Interactive Apps**,
then **Positron**, and select **Launch**.

## What is where

| Path | Purpose |
|---|---|
| `docker-compose.yml` | The services. The repository root is bind-mounted read-only at `/var/www/ood/apps/sys/positron` in the OOD container, so edits to the app apply on the next page load. |
| `.env` | Image tag, MariaDB version, and the Positron Server version the installer downloads. |
| `slurm/slurm.conf` | Replaces the tutorial's config on every Slurm container. Nodes report 2 CPUs and 5000 MB, enough for the app's 2.5 GB default. |
| `install-positron-server.sh` | Runs in the `installer` service. Downloads the archive for the container's architecture into `.cache/`, unpacks it into the `positron_server` volume, installs the wrapper and secrets. |
| `positron-server-wrapper.sh` | Installed as `bin/positron-server` in the volume. Mints a signed key when `signing-key.pem` is present and no `.lic` file is installed. Otherwise it starts the real server unchanged. |
| `compute/` | The Rocky Linux 9 compute node image. |
| `ondemand/entrypoint.sh` | Reissues the OOD certificate before the portal starts. |

## Useful commands

```bash
# Session logs for the last session
docker compose exec frontend bash -c \
  'cat $(ls -dt /home/hpcadmin/ondemand/data/sys/dashboard/batch_connect/sys/positron/output/* | head -1)/output.log'

# Slurm queue and job history
docker compose exec frontend squeue
docker compose exec frontend sacct -X

# OOD per-user log, for form errors
docker compose exec ondemand tail -50 /var/log/ondemand-nginx/hpcadmin/error.log

# Check the license on a compute node
docker compose exec cpn01 /opt/positron-server/resources/activation/linux/$(uname -m | sed 's/arm64/aarch64/')/license-manager status

# Re-run the installer after you change secrets/ or POSITRON_VERSION
docker compose up -d installer
```

## Stop and reset

```bash
docker compose stop          # keep the volumes
docker compose down -v       # remove containers and volumes, keep .cache/
```

## Limits

- The OOD image is OOD 3.0. The app also runs on OOD 4.x, but the local
  environment does not show the 4.x dashboard.
- The compute nodes have no GPU, so the GPU field only adds `--gres` to a job
  that Slurm then cannot place. Leave GPUs at 0.
- Apptainer is not installed in the containers, so the `apptainer_image`
  setting cannot be exercised here.
- Positron does not list the EPEL R install (`/usr/lib64/R`) in its
  interpreter picker on these nodes, although `R` runs for the session user.
  The R extension log shows no discovery output at all. Python sessions work.
  Until this is understood, the R items on the test checklist cannot be run
  here.

## Why these images

Two candidates were evaluated:

- [OSC/ondemand `Dockerfile.example`](https://github.com/OSC/ondemand/blob/master/Dockerfile.example)
  installs OOD on Rocky Linux 9 and nothing else. It has no scheduler, no
  compute node, and no user accounts, so each of those would need to be
  built and wired to OOD by hand.
- [ubccr/hpc-toolset-tutorial](https://github.com/ubccr/hpc-toolset-tutorial)
  publishes images for OOD, Slurm (controller, database, and nodes), LDAP,
  and a login node, with OOD already configured for the cluster and for the
  `/rnode/` reverse proxy. The images are published for amd64 and arm64.

The tutorial needs less setup, so this environment uses its images. It drops
the ColdFront, XDMoD, and MongoDB services, which the app does not need. The
tutorial repository is archived, but the `2025.02` images are still on Docker
Hub and run as published.

Two parts are replaced:

- The compute nodes are built from [`compute/Dockerfile`](compute/Dockerfile)
  on Rocky Linux 9, with Slurm at the tutorial's version, R, Python 3.12, and
  `ipykernel`. The tutorial's Rocky Linux 8 nodes cannot run the
  `license-manager` binary that Positron Server bundles, which needs glibc
  2.34 and OpenSSL 3.
- The OOD container reissues its TLS certificate at start, through
  [`ondemand/entrypoint.sh`](ondemand/entrypoint.sh), because the published
  image's certificate has expired.

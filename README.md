# positron-server-ood

An [Open OnDemand](https://openondemand.org/) interactive app that launches
[Positron Server](https://github.com/posit-dev/positron) on a compute node and
opens it in the browser.

Positron is a data science IDE built on Code OSS, with a console, variables
pane, data explorer, and plot viewer for R and Python. Positron Server runs the
IDE on a cluster node, so users need no local install.

## Documentation

The documentation site at
<https://posit-dev.github.io/positron-server-ood/> covers:

- [Get started](https://posit-dev.github.io/positron-server-ood/get_started.html):
  install Positron Server, place the license, install the app, launch a session.
- [Configuration](https://posit-dev.github.io/positron-server-ood/configuration.html):
  every form field and site setting, Apptainer, GPUs, bind mounts.
- [Troubleshooting](https://posit-dev.github.io/positron-server-ood/troubleshooting.html):
  a session that does not start.
- [Test checklist](https://posit-dev.github.io/positron-server-ood/test_checklist.html):
  the list to run after install.

The source for the site is in [`docs/`](docs/). To build a PDF of the whole
site, see [`docs/README.md`](docs/README.md).

## Quick install

On the OOD host:

```bash
cd /var/www/ood/apps/sys
git clone https://github.com/posit-dev/positron-server-ood.git positron
```

Then set `cluster` and `positron_server_dir` at the top of
[`form.yml`](form.yml), and follow
[Get started](https://posit-dev.github.io/positron-server-ood/get_started.html)
for the server install and the license file.

## Requirements

- Open OnDemand 3.0 or newer with a Slurm cluster, and `rnode_uri` enabled.
- Positron Server installed where the compute nodes can read it.
- A Positron Server license file from Posit.
- At least 2.5 GB of RAM per session.

## Local validation

[`dev/`](dev/) stands up OOD with a two-node Slurm cluster in Docker, with this
app installed, so you can launch a session before you deploy to a real cluster.

## Related projects

- [jupyter-positron-server](https://github.com/posit-dev/jupyter-positron-server):
  Positron Server in JupyterHub.
- [Positron](https://github.com/posit-dev/positron): the IDE this app serves.

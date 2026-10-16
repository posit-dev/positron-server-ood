# Compute node for the local cluster. Rocky Linux 9, because the bundled
# license-manager needs glibc 2.34 and OpenSSL 3. Slurm is built from source at
# the same version as the tutorial images that run slurmctld and slurmdbd.
FROM rockylinux/rockylinux:9
ARG SLURM_VERSION=24.05.5

RUN dnf install -y epel-release dnf-plugins-core && dnf config-manager --set-enabled crb && \
    dnf install -y munge gcc gcc-c++ make bzip2 perl pam-devel readline-devel hwloc-devel \
      openssl-devel iproute lsof procps-ng hostname which tar gzip \
      python3.12 python3.12-pip R-core && \
    dnf clean all

RUN dnf install -y munge-devel && dnf clean all

RUN curl -fsSL -o /tmp/slurm.tar.bz2 https://download.schedmd.com/slurm/slurm-${SLURM_VERSION}.tar.bz2 && \
    cd /tmp && tar xf slurm.tar.bz2 && cd slurm-${SLURM_VERSION} && \
    ./configure --prefix=/usr --sysconfdir=/etc/slurm > /dev/null && \
    make -j"$(nproc)" > /dev/null && make install > /dev/null && \
    rm -rf /tmp/slurm* && \
    mkdir -p /var/spool/slurmd /var/run/slurmd /var/log/slurm

# Same uids as the tutorial LDAP accounts, so the shared /home volume lines up.
RUN groupadd -g 1000 slurm && useradd -u 1000 -g slurm -r slurm && \
    for u in hpcadmin:1001 cgray:1002 sfoster:1003 csimmons:1004 astewart:1005; do \
      groupadd -g "${u#*:}" "${u%%:*}" && useradd -u "${u#*:}" -g "${u#*:}" -M -d "/home/${u%%:*}" -s /bin/bash "${u%%:*}"; \
    done

RUN python3.12 -m pip install --no-cache-dir ipykernel pandas matplotlib

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["slurmd"]

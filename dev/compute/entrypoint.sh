#!/bin/bash
set -e

# The shared munge key is owned by the tutorial image's munge uid, so copy it.
install -d -o munge -g munge -m 755 /run/munge
install -d -o munge -g munge -m 700 /var/lib/munge
install -o munge -g munge -m 400 /etc/munge/munge.key /var/lib/munge/key
runuser -u munge -- /usr/sbin/munged --key-file=/var/lib/munge/key

until (echo > /dev/tcp/slurmctld/6817) 2> /dev/null; do
  echo "-- waiting for slurmctld"
  sleep 2
done

exec /usr/sbin/slurmd -Dv

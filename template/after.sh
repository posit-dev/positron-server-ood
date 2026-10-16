echo "$(date): Waiting for Positron Server to open port ${port}..."
for ((i = 0; i < 600; i++)); do
  if port_used "${host}:${port}"; then
    echo "$(date): Positron Server is listening on port ${port}"
    break
  fi
  if ! kill -0 "${SCRIPT_PID}" 2>/dev/null; then
    echo "$(date): positron-server exited before it opened port ${port}. See the messages above."
    clean_up 1
  fi
  if (( i == 599 )); then
    echo "$(date): Timed out waiting for Positron Server to open port ${port}"
    clean_up 1
  fi
  sleep 1
done
sleep 2

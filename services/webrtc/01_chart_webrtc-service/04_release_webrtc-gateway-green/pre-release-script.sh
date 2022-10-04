# Pre-script: insert turn ip address in override values
###############################################################################

echo "Validate that CoTurn LB obtained public IP"

for i in {1..24}; do
  TURNIP=$(kubectl get svc -l "servicename=webrtc-coturn,color=green"  --no-headers | awk '{print $4}')
  echo "$TURNIP"
  [[ $TURNIP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && break
  [[ $i == 24 ]] && echo "ERROR: can't obtain CoTurn LB public IP" && exit 1
  echo "waiting for LB public IP.." && sleep 5
done

echo "successfully obtained CoTurn public IP: $TURNIP"

# Replacing turn-ip in override-values
echo "Replacing turn ip address in file: $(pwd)/override_values.yaml"
cat override_values.yaml | sed "s/127\.0\.0\.1/${TURNIP}/g" > override_values.tmp \
  && mv override_values.tmp override_values.yaml

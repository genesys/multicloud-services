cat << EOF | kubectl apply -n $NS -f - 
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: voice-voicemail-pvc
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 3Gi
  storageClassName: $STORAGE_CLASS_RWX
EOF


cat << EOF | kubectl apply -n $NS -f - 
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    service: voicemail
    servicename: voicemail
  name: voice-voicemail-tenants-list
data:
  # Add all tenants here
  tenants.json: |
    [
        {
            "name": "t$TENANT_SID",
            "tenant_id": "t$TENANT_SID",
            "tenant_uuid": "$TENANT_UUID",
            "status": "INIT"
        }
    ]
EOF

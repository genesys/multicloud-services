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
  storageClassName: standard-rwx
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
            "name": "t100",
            "tenant_id": "t100",
            "tenant_uuid": "9350e2fc-a1dd-4c65-8d40-1f75a2e080dd",
            "status": "INIT"
        }
    ]
EOF

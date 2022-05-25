###############################################################################
# All secrets sould be saved in secrets: bds-manual-secrets
#                  
# See README file or official documentation:
# https://all.docs.genesys.com/BDS/Current/BDSPEGuide/Provision#OpenShift
###############################################################################


###############################################################################
#             Create ServiceAccount, if not exist
###############################################################################
! (kubectl get sa genesys > /dev/null 2>&1)  && kubectl create sa genesys

###############################################################################
#            Create PVC, if not exist
###############################################################################
! (kubectl get pvc bds-pvc > /dev/null 2>&1) && kubectl create -f bds-pvc.yaml 

return 0
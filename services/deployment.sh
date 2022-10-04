#!/usr/bin/env bash

# This is CI/CD-agnostic shell script
# but will be used as part of your pipeline

###################################################################################
# Current workdir is $SERVICE

source ../helpers.sh
source ../global-defaults.sh

print_log "START: $SERVICE ($FULLCOMMAND) in namespace $NS"
SECONDS=0

# Read deployment secrets
fetch_deployment_secrets default global-deployment-secrets
fetch_deployment_secrets

# Run pre-deployment init script if present (common for all charts)
[[ "$COMMAND" != "uninstall" ]] && run_init

# FOR EVERY HELM CHART ############################################################
# ℹ️ Notice: in application folder we should have subfolder with following naming: 
#     [0-9][0-9]_chart_<chart-name> 
# where: 
#   - digits define the instalation order
#   - chart-name is name of chart to be installed
# The chart-name will be used in command:
#     helm install release-name helm-repo/chart-name
# ##################################################################################
for DIR_CH in [0-9][0-9]_chart_*$CHART_NAME*/; do
    
    CHART=$([[ -d "$DIR_CH" ]] && echo $DIR_CH | sed 's/[0-9][0-9]_chart_//' | sed 's/\///')
    
    DIR_CH=$(echo $DIR_CH | sed 's/\///')
    cd $DIR_CH

    # 🖊️ (Optional) EDIT 1st line of chart.ver file with chart version number
    CHART_VER=$(head -n 1 chart.ver | awk '{print $1}')
    
    PARAMS_CH="helm_repo/$CHART -n $NS"

    case $COMMAND in

    install)
        print_log "Installing chart ${SERVICE}/${DIR_CH} ..."
        CMD="upgrade"
        PARAMS_CH+=" --install"
        ;;

    uninstall)
        print_log "Uninstalling chart ${SERVICE}/${DIR_CH} ..."
        CMD="uninstall"
        PARAMS_CH=""
        ;;

    validate)
        print_log "Validating chart ${SERVICE}/${DIR_CH} ..."
        CMD="upgrade"
        PARAMS_CH+=" --install --dry-run"
        ;;

    *)
        error_exit "❌ Wrong command"
        ;;

    esac

    # Run pre-deployment init script if present (common for all releases)
    [[ "$CMD" != "uninstall" ]] && run_init
    
    # FOR EVERY HELM RELEASE ###########################################################
    # ℹ️ Notice: in chart folder you should have subfolder with name in format: 
    #      [0-9][0-9]_release_<release-name>
    # where:
    #  - digits define the instalation order 
    #  - release-name is name of release to be installed
    # The release-name will be used in command:
    #     helm install release-name helm-repo/chart-name
    #
    # If you want to run some preparing script (for ex: init database, check conditions) 
    # before installing, place your code in pre-relese-script.sh in release subfolder
    #
    # If you want to run some post-installing script (for ex: validate something),
    # place you code in post-relese-script.sh in release subfolder
    # ##################################################################################
    for DIR_RL in [0-9][0-9]_release_*$RL_NAME*/; do
        
        DIR_RL=$(echo $DIR_RL | sed 's/\///')
        RELEASE=$([[ -d "$DIR_RL" ]] && echo $DIR_RL | sed -e 's/[0-9][0-9]_release_//')

        # Tenant-specific releases should include tenant SID
        if tenant_specific_release $RELEASE; then RELEASE+="-$TENANT_SID"; fi

        # simply uninstall release and contunue loop
        if [ "$CMD" == "uninstall" ]; then
            helm uninstall $RELEASE
            continue
        fi

        cd $DIR_RL

        PARAMS="$PARAMS_CH"  #avoid leaking parameters between releases

        # Run pre-release-script if exists
        [[ -f pre-release-script.sh ]] \
            && print_log "${SERVICE}/${DIR_CH}/${DIR_RL} - run pre-release-script" \
            && source pre-release-script.sh
        
        # in pre-release script we might want to skip helm installation
        if [[ "$CMD" ]] && [[ "$CHART" ]] && [[ "$RELEASE" ]]
        then

            # Parse and include all overrides to helm command line
            print_log "processing override files"
            cd ..      && PARAMS+=" $(list_override_files)"
            cd $DIR_RL && PARAMS+=" $(list_override_files)"

            print_log "${SERVICE}/${DIR_CH}/${DIR_RL} - run Helm"

            try_helm_debug   # Run helm debug if required

            print_log "RUN: helm $CMD $RELEASE $PARAMS --version=$CHART_VER"
            helm $CMD $RELEASE $PARAMS --version=$CHART_VER

            # Run post-release-script if exists
            [[ -f post-release-script.sh ]] \
                && print_log "${SERVICE}/${DIR_CH}/${DIR_RL} - run post-release-script" \
                && source post-release-script.sh
        fi
        
        print_log "${SERVICE}/${DIR_CH}/${DIR_RL} - release completed"
        cd ..
    
    done

    print_log "${SERVICE}/${DIR_CH} - chart completed"
    cd ..

done

print_log "END"
print_log "$(($SECONDS / 60)) min $(($SECONDS % 60)) sec elapsed"
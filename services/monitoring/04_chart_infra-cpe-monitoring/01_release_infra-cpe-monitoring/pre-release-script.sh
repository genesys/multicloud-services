# Helm does not allow to create or update resource created outside of this release
# Hence kubectl instead of Helm, to add/update alerts and dashboards

print_log "Installing Infra monitoring chart"

[[ "$COMMAND" == "install" ]]  && export PARAMS=" --install"
[[ "$COMMAND" == "validate" ]] && export PARAMS=" --install --dry-run"

# install from local directory
export PARAMS+=" $(pwd)/helm"
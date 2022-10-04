###############################################################################
# cutover.sh - script for switching blue -> green, or green -> blue versions
# Applicable for webrtc application
#
# It can be run in shell (yq - required) in current directory, or just change
# deployment color manually  in files FLN for parameters SW
###############################################################################
FLN="01_chart_webrtc-service/05_release_webrtc-ingress/override_values.yaml"
SW=deployment.color

webrtc_color=$(yq eval .$SW $FLN)

if [[ "$webrtc_color" == "green" ]];then
	new_color=blue
else
	new_color=green
fi

echo "Changing $SW to new color: <$new_color> in $FLN file..."
yq eval ".$SW |= \"$new_color\"" $FLN > ${FLN}.tmp && mv ${FLN}.tmp ${FLN}

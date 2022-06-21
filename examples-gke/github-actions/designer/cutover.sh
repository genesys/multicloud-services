###############################################################################
# cutover.sh - script for switching blue -> green, or green -> blue versions
# Applicable for designer and designer-das applications
#
# It can be run in shell (yq - required) in current directory, or just change
# deployment color manually  in files DES_FL and DAS_FL for parameters DES_SW
# and DAS_SW respectively
###############################################################################
DES_FL="03_chart_designer/override_values.yaml"
DES_SW=designer.deployment.color

DAS_FL="05_chart_designer-das/override_values.yaml"
DAS_SW=das.deployment.color

des_color=$(yq eval .$DES_SW $DES_FL)
das_color=$(yq eval .$DAS_SW $DAS_FL)

if [[ "$des_color" == "$das_color" ]];then
	if [[ "$des_color" == "green" ]];then
		new_color=blue
	else
		new_color=green
	fi
else 
	echo "Designer deployment color is not consistent with designer DAS deployment color"
	exit 1
fi

echo "Changing $DES_SW to new color: <$new_color> in $DES_FL file..."
yq eval ".$DES_SW |= \"$new_color\"" $DES_FL > ${DES_FL}.tmp && mv ${DES_FL}.tmp ${DES_FL}

echo "Changing $DAS_SW to new color: <$new_color> in $DAS_FL file..."
yq eval ".$DAS_SW |= \"$new_color\"" $DAS_FL > ${DAS_FL}.tmp && mv ${DAS_FL}.tmp ${DAS_FL}
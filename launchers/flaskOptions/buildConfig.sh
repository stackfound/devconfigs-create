#!/bin/bash

# Your buildConfig.sh script needs to parse the options in the devconfigs.yaml
# file and then build and place a config.json file in the launcher directory, which can
# be accessed at the path stored in the provided $LAUNCHER_DIRECTORY variable.
# We typically use a _config.json placeholder file that is mostly complete, and edit
# the file contents using jq to create our config.json file.

cat $LAUNCHER_DIRECTORY/_config.json > $LAUNCHER_DIRECTORY/config.json

options=($(yq e '.tasks.'$repository.$launcher' | to_entries | .[] | .key' $DEVCONFIGS_YML))
for option in "${options[@]}"; do
    option_value=$(yq e '.launchers.'$repository.$launcher.$option $DEVCONFIGS_YML)
    case $option in
        # add cases here to handle each option specified in devconfigs.yaml
        appPath)
            APP_PATH=$option_value
            jq -r --arg val "$APP_PATH" '.env.FLASK_APP |= $val' $LAUNCHER_DIRECTORY/config.json > $LAUNCHER_DIRECTORY/tmp.json && mv $LAUNCHER_DIRECTORY/tmp.json $LAUNCHER_DIRECTORY/config.json
            ;;
        port)
            PORT=$option_value
            jq -c ".args |= .+ [--port, $PORT]" $LAUNCHER_DIRECTORY/config.json > $LAUNCHER_DIRECTORY/tmp.json && mv $LAUNCHER_DIRECTORY/tmp.json $LAUNCHER_DIRECTORY/config.json
    esac
done
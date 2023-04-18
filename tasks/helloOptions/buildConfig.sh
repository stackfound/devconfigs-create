#!/bin/bash

# your buildConfig.sh script needs to parse the options in the devconfigs.yaml
# file and then build and place a config.json file in the task directory, which can
# be accessed at the path stored in the provided $TASK_DIRECTORY variable.
# We typically use a _config.json placeholder file that is mostly complete, and edit
# the file contents using jq to create our config.json file.

options=($(yq e '.tasks.'$repository.$task' | to_entries | .[] | .key' $DEVCONFIGS_YML))
for option in "${options[@]}"; do
    option_value=$(yq e '.tasks.'$repository.$task.$option $DEVCONFIGS_YML)
    case $option in
        # add cases here to handle each option specified in devconfigs.yaml
        name)
            NAME=$option_value
            ;;
        title)
            TITLE="$option_value "
    esac
done

# In this case, we build the task command with the environment variables we saved
# from each option above

TASK_COMMAND="echo Hello, $TITLE$NAME"
cat $TASK_DIRECTORY/_config.json > $TASK_DIRECTORY/config.json
jq -r --arg val "$TASK_COMMAND" '.command |= $val' $TASK_DIRECTORY/_config.json > $TASK_DIRECTORY/config.json
#!/bin/bash

# ===== Settings =====
android_manifest=''
apk='' #usually in $app-name/build/apk/
hockey_app_id=''
hockey_api_token=''
git_upload_branch=''

# ===== Vars =====
release_notes="release_notes.tmp.txt"
last_hockey_push="lastCommit.txt"
notify=true

# ===== Setup =====
# Expanding aliases for easy gradle setup
shopt -s expand_aliases
source ~/.bash_profile

# ===== Functions =====
function updateVersionCode {
	for line in `grep -o 'android:versionCode="[0-9].*"' $android_manifest`
	do
        versionCode=$(sed 's/[^0-9]//g' <<< ${line})
        nextVersion=$(($versionCode + 1))

        cp "$android_manifest" "$android_manifest.buff"
        sed "s/android:versionCode=\"$versionCode\"/android:versionCode=\"$nextVersion\"/" "$android_manifest.buff" > "$android_manifest"
        rm "$android_manifest.buff"

        break #Ensuring it only does it once, even if you have android:versionCode more than once
	done
}

function upload {
	#Getting changes
	if [[ -f "$last_hockey_push" ]]; then
    	lastSHA=`cat $last_hockey_push`
    	currentSHA=`git rev-parse HEAD`
		git log --pretty=oneline --abbrev-commit $lastSHA...$currentSHA | cut -d" " -f2- > "$release_notes"
    #No notes
    else
    	echo "No notes" > "$release_notes"
	fi

	# Uploading
	puck 	-submit=auto \
			-notify="$notify" \
			-download=true \
			-notes_path="$release_notes" \
			-app_id="$hockey_app_id" \
			-api_token="$hockey_api_token" \
			"$apk"

	# Removing changelog from filesystem
	rm "$release_notes"
}

function manageFlags {
	for flag in "$@"
	do
		# -silent: Causes no notification in HockeyApp
    	if [ "$flag" = "-silent" ]; then
    		echo "Running silent mode, there will be no HockeyApp notification."
    		notify=false
    	# Unknown Flag, causes an exit
    	else
    		echo "Unknown flag: $flag.  Exiting."
    		exit
    	fi
	done
}


# ===== Start =====
echo "Starting bash-hockey-puck"

echo "----- Flags"
manageFlags "$@"

echo "----- Ensuring we're in script's directory"
script_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $script_directory

echo "----- Checking out $git_upload_branch"
git checkout "$git_upload_branch"
git pull

echo "----- Updating Version Code"
updateVersionCode

echo "----- Building App"
gradle build

echo "----- Uploading to HockeyApp"
upload

echo "----- Pushing to GIT"
git add "$android_manifest"
git commit -am ":new: Bash-Hockey-Puck :new: Bumped version number"
git push origin "$git_upload_branch"

echo "----- Writing SHA"
git rev-parse HEAD > "$last_hockey_push"

echo "----- bash-hockey-puck finished"

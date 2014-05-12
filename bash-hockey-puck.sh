#!/bin/bash

# ===== Vars =====
android_manifest=''
apk='' #usually in $app-name/build/apk/
hockey_app_id=''
hockey_api_token=''
git_upload_branch=''

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
	puck -submit=auto -download=true -app_id="$hockey_app_id" -api_token="$hockey_api_token" "$apk"
}

# ===== Start =====
echo "Starting..."

# Ensuring we're in script's directory (should be in app root)
script_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $script_directory

echo "--- Checking out $git_upload_branch"
git checkout "$git_upload_branch"
git pull

echo "--- Updating Version Code"
updateVersionCode

echo "--- Building App"
gradle build

echo "--- Uploading to puck"
upload

echo "--- Pushing to GIT"
git add "$android_manifest"
git commit -am "bash-hockey-puck: Bumped version number"
git push origin "$git_upload_branch"
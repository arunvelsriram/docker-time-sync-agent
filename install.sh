#!/bin/bash
set -e

latest_release_tag() {
	curl -s https://api.github.com/repos/arunvelsriram/docker-time-sync-agent/releases/latest \
	| python -c "import sys, json; print json.load(sys.stdin)['tag_name']"
}

echo_me() {
	echo
	echo $*
	echo
}

username=$(id -u -n)
plist_filename="io.github.arunvelsriram.docker-time-sync-agent.plist"
tag_name=$(latest_release_tag)

echo_me "Preparing to install $tag_name..."
pushd /tmp

echo_me "Setting up scripts and binary files..."
curl -LOs https://github.com/arunvelsriram/docker-time-sync-agent/releases/download/$tag_name/Binaries.zip
unzip Binaries.zip
rm -f Binaries.zip
mv Binaries/update-docker-time Binaries/docker-time-sync-agent /usr/local/bin
rm -rf Binaries

echo_me "Setting up Launch Agent..."
curl -Os https://raw.githubusercontent.com/arunvelsriram/docker-time-sync-agent/master/$plist_filename
sed -i .backup "s/YOUR_USERNAME/$username/g" $plist_filename
cp $plist_filename ~/Library/LaunchAgents
launchctl unload ~/Library/LaunchAgents/$plist_filename 2>/dev/null
launchctl load ~/Library/LaunchAgents/$plist_filename

popd

echo_me "Logs can be viewed in Console.app or ~/.docker-time-sync-agent.log"
echo All Done!

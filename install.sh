#!/bin/bash

tag="v1.0.0"
username=$(id -u -n)
plist_filename="io.github.arunvelsriram.docker-time-sync-agent.plist"

pushd /tmp
echo
echo Setting up scrips and binary files...
curl -LO https://github.com/arunvelsriram/docker-time-sync-agent/releases/download/$tag/Binaries.zip
unzip Binaries.zip
rm -f Binaries.zip
mv Binaries/update-docker-time Binaries/docker-time-sync-agent /usr/local/bin
rm -rf Binaries
echo
echo Setting up Launch Agent...
curl -O https://raw.githubusercontent.com/arunvelsriram/docker-time-sync-agent/master/$plist_filename
sed -i .backup "s/YOUR_USERNAME/$username/g" $plist_filename
cp $plist_filename ~/Library/LaunchAgents
launchctl unload ~/Library/LaunchAgents/$plist_filename 2>/dev/null
launchctl load ~/Library/LaunchAgents/$plist_filename
popd

echo
echo "Logs can be viewed in Console.app or ~/.docker-time-sync-agent.log"
echo All Done!

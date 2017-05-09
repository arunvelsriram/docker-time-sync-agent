# docker-time-sync-agent
`docker-time-sync-agent` is a tool to prevent time drift in Docker for Mac's HyperKit VM.

Docker daemon fails to update the VM's time after computer wakes up from sleep. The result is that VM's clock will be set to a past time. This inturn will make Docker containers use that time.

So what's the problem if the container's use a wrong time ?   
Some services (like S3, Okta) will block requests orginating from a source whose time is wrong. Few examples:

* Uploading to S3 will retun a `403 Forbidden`
* SAML Authentication with Okta will fail

`docker-time-sync-agent` listens to system wakeup event and runs a shell script (`update-docker-time`) that updates the VM's time. Time sync can be triggered manually anytime by running `update-docker-time`. 

Using `launchd`, `docker-time-sync-agent` can be made to autostart during login so that on every wakeup, time sync happens automatically.

## Installation

### Auto

`curl https://raw.githubusercontent.com/arunvelsriram/docker-time-sync-agent/master/install.sh | bash`

### Manual
1. Download the latest binaries from releases page
2. `unzip Binaries-Vx.y.z.zip`
3. `mv /Binaries-Vx.y.z/docker-time-sync-agent /usr/local/bin/`
4. `mv /Binaries-Vx.y.z/update-docker-time /usr/local/bin/`
5. Download this file [io.github.arunvelsriram.docker-time-sync-agent.plist](io.github.arunvelsriram.docker-time-sync-agent.plist)
6. Open it and replace 'YOUR_USERNAME' with your Mac's username
7. `mv /path/to/io.github.arunvelsriram.docker-time-sync-agent.plist` `~/Library/LaunchAgents/`
8. `launchctl load ~/Library/LaunchAgents/io.github.arunvelsriram.docker-time-sync-agent.plist`
9. Use `Console.app` and `~/.docker-time-sync-agent.log` file to see the logs
10. Put the computer in sleep mode and wake it up. After 30s from wakeup, time sync will happen

## Uninstallation

### Manual
1. Run the following commands from your terminal:
    
    ```
    launchctl unload ~/Library/LaunchAgents/io.github.arunvelsriram.docker-time-sync-agent.plist
    rm -f ~/Library/LaunchAgents/io.github.arunvelsriram.docker-time-sync-agent.plist
    rm -f /usr/local/bin/docker-time-sync-agent
    rm -f /usr/local/bin/update-docker-time
    rm -f ~/.docker-time-sync-agent.log
    ```

## Contributing
**Contributions are welcome**  
This is a Xcode Command Line Tool project. Clone the repo and open `docker-time-sync-agent.xcodeproj` in Xcode.   

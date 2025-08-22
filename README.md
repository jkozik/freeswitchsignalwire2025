# Freeswitch docker container linked to Signalwire 2025
I went to [docker hub](https://hub.docker.com/) and [searched for freeswitch](https://hub.docker.com/search?q=freeswitch).  I was looking for the office docker image.  I picked this one to base this project on [`safarov/freeswitch`](https://hub.docker.com/r/safarov/freeswitch).  It has over 1M downloads, and was only 2 months old.  

<img width="790" height="296" alt="image" src="https://github.com/user-attachments/assets/1c64263b-4a05-43f7-9cd2-7e1b340439c1" />

What I wanted to do was run a freeswitch container on my home LAN and connect it to Signalwire.  I wanted to do a setup that was easily reproducable. Containers are better for me that installing from source or packages. 

## Here's my target architecture:

<img width="1066" height="605" alt="image" src="https://github.com/user-attachments/assets/ad2141fd-8a38-4776-ad65-4224e5289bd2" />



## Here's my firewall settings
<img width="1414" height="385" alt="image" src="https://github.com/user-attachments/assets/7ce2c92e-4446-410a-a7d7-b975d3c6d8a7" />

## download repository
Clone my repository and look at the `docker-compose.yaml` file.
```
jkozik@u2004:~/projects$ git clone https://github.com/jkozik/freeswitchsignalwire2025.git
Cloning into 'freeswitchsignalwire2025'...
remote: Enumerating objects: 21, done.
remote: Counting objects: 100% (21/21), done.
remote: Compressing objects: 100% (19/19), done.
remote: Total 21 (delta 7), reused 8 (delta 0), pack-reused 0 (from 0)
Receiving objects: 100% (21/21), 6.01 KiB | 1.20 MiB/s, done.
Resolving deltas: 100% (7/7), done.
jkozik@u2004:~/projects$ cd freeswitchsignalwire2025

jkozik@u2004:~/projects/freeswitchsignalwire2025$ cat docker-compose.yml
services:
  freeswitch:
    container_name: freeswitch
    image: safarov/freeswitch
    network_mode: "host"
    environment:
      SOUND_RATES: "8000:16000"
      SOUND_TYPES: "en-us-callie"
    cap_add:
      - SYS_NICE # Enable RT features
    env_file: .env
    volumes:
      - './configs/freeswitch:/etc/freeswitch'
      - './configs/freeswitch-sounds:/usr/share/freeswitch/sounds'
      - ./configs/storage:/var/lib/freeswitch/storage
      - ./logs:/var/log/freeswitch/

    command: ["freeswitch", "-nonatmap", "-nonat"]

jkozik@u2004:~/projects/freeswitchsignalwire2025$
```
A few things about the docker-compose.yaml file.  The volumes are choosen so that the configurations, tokens, sound files and logs can be saved across restarts of the docker container.  They are read-only and nothing needs to be edited from the host login. 

The image safarov/freeswitch is used as is.  [Its docker hub page](https://hub.docker.com/r/safarov/freeswitch) suggests usage.  I wrote the docker compose file based on those notes.  I did not setup a systemd service. 

The .env file is pulled in, but never really accessed.  It is used by a post installation script.

## docker compose up -d

```
jkozik@u2004:~/projects/freeswitchsignalwire2025$ docker compose up -d
[+] Running 1/1
 ✔ Container freeswitch  Started                                                                                                                                             0.4s
jkozik@u2004:~/projects/freeswitchsignalwire2025$ cd logs
jkozik@u2004:~/projects/freeswitchsignalwire2025/logs$ ls
cdr-csv  freeswitch.log  freeswitch.xml.fsxml
```
Here's the first several lines of  the freeswitch container boots log.
```
jkozik@u2004:~/projects/freeswitchsignalwire2025/logs$ head -100 freeswitch.log
2025-07-24 02:54:09.265084 [CONSOLE] switch_loadable_module.c:1803 Successfully Loaded [mod_logfile]
2025-07-24 02:54:09.266847 [CONSOLE] switch_loadable_module.c:1803 Successfully Loaded [mod_enum]
2025-07-24 02:54:09.266875 [NOTICE] switch_loadable_module.c:292 Adding Dialplan 'enum'
2025-07-24 02:54:09.266894 [NOTICE] switch_loadable_module.c:350 Adding Application 'enum'
2025-07-24 02:54:09.266904 [NOTICE] switch_loadable_module.c:412 Adding API Function 'enum'
2025-07-24 02:54:09.266913 [NOTICE] switch_loadable_module.c:412 Adding API Function 'enum_auto'
2025-07-24 02:54:09.267309 [DEBUG] mod_cdr_csv.c:368 Adding default template.
2025-07-24 02:54:09.267343 [DEBUG] mod_cdr_csv.c:415 Adding template sql.
2025-07-24 02:54:09.267347 [DEBUG] mod_cdr_csv.c:415 Adding template example.
2025-07-24 02:54:09.267350 [DEBUG] mod_cdr_csv.c:415 Adding template snom.
2025-07-24 02:54:09.267352 [DEBUG] mod_cdr_csv.c:415 Adding template linksys.
2025-07-24 02:54:09.267355 [DEBUG] mod_cdr_csv.c:415 Adding template asterisk.
2025-07-24 02:54:09.267357 [DEBUG] mod_cdr_csv.c:415 Adding template opencdrrate.
2025-07-24 02:54:09.267648 [CONSOLE] switch_loadable_module.c:1803 Successfully Loaded [mod_cdr_csv]

jkozik@u2004:~/projects/freeswitchsignalwire2025/logs$
```
More importantly, here's the tail of the log file
```
jkozik@u2004:~/projects/freeswitchsignalwire2025/logs$ tail freeswitch.log
2025-07-24 02:54:11.428505 [DEBUG] mod_event_socket.c:2967 Socket up listening on :::8021
2025-07-24 02:54:11.428655 [DEBUG] switch_loadable_module.c:943 Chat Thread Started
2025-07-24 02:54:11.428677 [INFO] switch_time.c:626 Clock synchronized to system time.
2025-07-24 02:54:11.428697 [DEBUG] switch_loadable_module.c:943 Chat Thread Started
2025-07-24 02:54:11.868717 [NOTICE] mod_signalwire.c:379 Go to https://signalwire.com to set up your Connector now! Enter connection token 25e17bd7-c8cd-422f-8e50-dfca2ccc7a3b
2025-07-24 02:54:11.868717 [INFO] mod_signalwire.c:1009 Next SignalWire adoption check in 1 minutes
2025-07-24 02:55:12.028697 [NOTICE] mod_signalwire.c:379 Go to https://signalwire.com to set up your Connector now! Enter connection token 25e17bd7-c8cd-422f-8e50-dfca2ccc7a3b
2025-07-24 02:55:12.028697 [INFO] mod_signalwire.c:1009 Next SignalWire adoption check in 2 minutes
2025-07-24 02:57:12.188679 [NOTICE] mod_signalwire.c:379 Go to https://signalwire.com to set up your Connector now! Enter connection token 25e17bd7-c8cd-422f-8e50-dfca2ccc7a3b
2025-07-24 02:57:12.188679 [INFO] mod_signalwire.c:1009 Next SignalWire adoption check in 3 minutes
```
The token above needs to be entered into the Signalwire.com portal to connect this freeswitch instance to my account on the Signalwire service. 

## Run initsetup.sh script

The [`safarov/freeswitch`](https://hub.docker.com/r/safarov/freeswitch) needs to be tweaked.  I have a script that applies the changes that I made.

```
jkozik@u2004:~/projects/freeswitchsignalwire2025$ . ./initsetup.sh
enter initsetup.sh
Change default password
Copy SignalWire dialplan files.  Incoming/Outgoing
Successfully copied 2.56kB to freeswitch:/etc/freeswitch/dialplan/default/
Successfully copied 2.05kB to freeswitch:/etc/freeswitch/dialplan/default/
Set RTP Start/End Ports to match home network
inactivate IPv6
jkozik@u2004:~/projects/freeswitchsignalwire2025$
```

Here's brief discussion.  Everytime I setup freeswitch, I manually tweak some of the setup after installation.  This simple script runs from the host environment and changes things in the running container.  
- I change the default password
- Signalwire dialplan support.  Freeswitch's dialing plan does not contain default support for Signalwire SIP trunking.  In the [mod_signalwire](https://developer.signalwire.com/freeswitch/FreeSWITCH-Explained/Modules/mod_signalwire_19595544/#3-dialplan-sample) documentation, it shows an example dialing plan segment needed to link the Signalwire / Freeswitch connector into a Freeswitch installation
- RTP Ports.  My home network has multiple VoIP services.  I want Freeswitch to use a very specific range of ports.  This reflects in my firewall settings and the switch.conf.xml file.
- IPv6.  I don't trust my IPv6 setup at home.  Thus I turned off Freeswitch's IPv6 profiles.

These simple tweaks that I do, I forget them.  Then a year later I create a new Freeswitch environment and have to rediscover them.  Thus I document here these changes.

Now, trigger Freeswitch to reload its settings files:
```
jkozik@u2004:~/projects/freeswitchsignalwire2025$ docker exec -it freeswitch  sh -c "fs_cli -x reloadxml"
+OK [Success]
```

## Verify Basic Functionality
The Freeswitch container from [`safarov/freeswitch`](https://hub.docker.com/r/safarov/freeswitch) is running.  I have applied the initalsetup.sh script.  Let's verify some basics.
### Verify SIP Stack
```
jkozik@u2004:~/projects/freeswitchsignalwire2025$ docker exec -it freeswitch  sh -c "fs_cli -x 'sofia status'"
                     Name          Type                                       Data      State
=================================================================================================
            external-ipv6       profile                   sip:mod_sofia@[::1]:5080      RUNNING (0)
          192.168.100.128         alias                                   internal      ALIASED
                 external       profile          sip:mod_sofia@69.243.158.102:5080      RUNNING (0)
    external::example.com       gateway                    sip:joeuser@example.com      NOREG
            internal-ipv6       profile                   sip:mod_sofia@[::1]:5060      RUNNING (0)
                 internal       profile          sip:mod_sofia@69.243.158.102:5060      RUNNING (0)
=================================================================================================
4 profiles 1 alias

jkozik@u2004:~/projects/freeswitchsignalwire2025$
```

Note:  here, the Signalwire connector is not setup.  I am just trying to verify basic Freeswitch functionality.  

### Verify SIP registrations
Note from my diagram above, I have two VoIP clients on my home LAN, configured to point to port 5060 of the Freeswitch.  They are on.  Here's what Freeswitch's SIP stack sees:
```
jkozik@u2004:~/projects/freeswitchsignalwire2025$ docker exec -it freeswitch  sh -c "fs_cli -x 'show registrations'"
reg_user,realm,token,url,expires,network_ip,network_port,network_proto,hostname,metadata
1002,192.168.100.128,0_3443613935@192.168.100.94,sofia/internal/sip:1002@192.168.100.94:5060;transport=TCP,1753385645,192.168.100.94,11807,tcp,u2004.kozik.net,
1001,192.168.100.128,HrPIgrWZbLjx-jeRJKXmKw..,sofia/internal/sip:1001@192.168.100.122:64379;rinstance=838a90f680202103;transport=UDP,1753382108,192.168.100.122,64379,udp,u2004.kozik.net,
2 total.
jkozik@u2004:~/projects/freeswitchsignalwire2025$
```
### Client 1001 calls client 1002
<img width="283" height="124" alt="image" src="https://github.com/user-attachments/assets/b6e9e90e-133f-4a68-8f32-001622c5407d" />

Just a simple test call.  They answer just fine.  Here's a super brief SIP trace.

<img width="1288" height="228" alt="image" src="https://github.com/user-attachments/assets/7aae4980-0117-4538-9047-b19d00b2b6fc" />

<img width="1375" height="566" alt="image" src="https://github.com/user-attachments/assets/e7ffb505-6e86-46af-81e5-00fff4b47904" />

In the logs/freeswitch.log file, there's tons of detail. It is worth learning.  But not for this note.

# Signalwire to Freeswitch Connector
<img width="366" height="268" alt="image" src="https://github.com/user-attachments/assets/4ccd62d9-43e8-458f-9a37-306321e2bf19" />
This is the most important part for me.  The Freeswitch setup is naked without the Signalwire connection.  This is really easy, but it took me a long time. 

The key reference is Omid's youtube video:
<img width="1101" height="588" alt="image" src="https://github.com/user-attachments/assets/361dfcfa-1b6c-44a3-a3b6-16b163827b3d" />
[Learn FreeSWITCH (Part8) - SignalWire Connector](https://www.youtube.com/watch?v=ax1uL4Z9Nao&t=63s)

My freeswitch instance was configured with the mod_signalwire module.  It is cycling, trying to connect to the Signalwire server.  Tailing the log file, you see this:
```
jkozik@u2004:~/projects/freeswitchsignalwire2025$ grep  mod_signalwire.c logs/freeswitch.log  | tail
2025-07-24 19:09:47.748686 [NOTICE] mod_signalwire.c:379 Go to https://signalwire.com to set up your Connector now! Enter connection token 25e17bd7-c8cd-422f-8e50-dfca2ccc7a3b
2025-07-24 19:09:47.748686 [INFO] mod_signalwire.c:1009 Next SignalWire adoption check in 15 minutes
2025-07-24 19:24:47.028733 [NOTICE] mod_signalwire.c:379 Go to https://signalwire.com to set up your Connector now! Enter connection token 25e17bd7-c8cd-422f-8e50-dfca2ccc7a3b
jkozik@u2004:~/projects/freeswitchsignalwire2025$
```
Take that token to Signalwire->Integrations, "Connect to Freeswitch" on my signalwire.com portal.  Create a connection and link it to my signalwire phone number 630-387-XXXX.  Follow [Omid's youtube video](https://www.youtube.com/watch?v=ax1uL4Z9Nao&t=63s). 
## Reload mod_signalwire
The Freeswitch algorithm checks the Signalwire service once every 15 minutes.  I don't want to wait that long, thus, I did a reload:
```
jkozik@u2004:~/projects/freeswitchsignalwire2025$ docker exec -it freeswitch  sh -c "fs_cli -x 'reload mod_signalwire'"
+OK Reloading XML
+OK module unloaded
+OK module loaded
```
Check the log files:
```
jkozik@u2004:~/projects/freeswitchsignalwire2025$ grep  mod_signalwire.c logs/freeswitch.log  | tail -f
2025-07-24 21:05:20.228707 [INFO] mod_signalwire.c:964 Disconnecting from SignalWire
2025-07-24 21:05:20.550307 [CONSOLE] mod_signalwire.c:915 Welcome to
2025-07-24 21:05:20.550307 [INFO] mod_signalwire.c:616
2025-07-24 21:05:20.808744 [INFO] mod_signalwire.c:404 SignalWire adoption of this FreeSWITCH completed
2025-07-24 21:05:22.108725 [INFO] mod_signalwire.c:524 SignalWire Session State Change: [Normal=>Online] Status: 0 Reason: Manager completed state change request
2025-07-24 21:05:23.868717 [INFO] mod_signalwire.c:1030 Connected to SignalWire
2025-07-24 21:05:25.108720 [DEBUG] mod_signalwire.c:1103 "<?xml version="1.0"?><document type="freeswitch/xml"><section name="configuration" description="Various Configuration"><configuration name="sofia.conf" description="sofia Endpoint"><profiles><profile name="signalwire"><gateways><gateway name="signalwire"><param name="username" value="caca1ddb40128438e53cb875f3faad0e" /><param name="password" value="3a2bbbac50be5c182436905c87c95a82" /><param name="proxy" value="jkozik-63eecb1e59a343e4b71567f323a71d52.sip.signalwire.com" /><param name="register" value="true" /><param name="register-transport" value="tls" /><param name="extension" value="auto_to_user" /><param name="dtmf-type" value="rfc2833" /><param name="caller-id-in-from" value="false" /><variables><variable name="rtp_secure_media" value="optional:AEAD_AES_256_GCM_8:AES_256_CM_HMAC_SHA1_80:AES_CM_128_HMAC_SHA1_80:AES_256_CM_HMAC_SHA1_32:AES_CM_128_HMAC_SHA1_32" /></variables></gateway></gateways><settings><param name="debug" value="0" /><param name="dialplan" value="signalwire" /><param name="context" value="default" /><param name="rtp-timer-name" value="soft" /><param name="rtp-ip" value="192.168.100.128" /><param name="sip-ip" value="192.168.100.128" /><param name="ext-rtp-ip" value="69.243.158.102" /><param name="ext-sip-ip" value="69.243.158.102" /><param name="rtp-timeout-sec" value="300" /><param name="rtp-hold-timeout-sec" value="1800" /><param name="sip-port" value="6050" /><param name="tls" value="True" /><param name="tls-only" value="true" /><param name="tls-bind-params" value="transport=tls" /><param name="tls-sip-port" value="6050" /><param name="tls-verify-date" value="true" /><param name="tls-verify-policy" value="none" /><param name="tls-verify-depth" value="2" /><param name="codec-prefs" value="OPUS,G722,PCMU,PCMA,G729,VP8,H264" /><param name="inbound-codec-negotiation" value="generous" /><param name="inbound-late-negotiation" value="true" /><param name="manage-presence" value="false" /><param name="auth-calls" value="false" /></settings></profile></profiles></configuration></section></document>"
2025-07-24 21:05:25.108720 [INFO] mod_signalwire.c:1142 gwlist = "Invalid Profile [signalwire]"
2025-07-24 21:05:25.108720 [INFO] mod_signalwire.c:1115 profile MD5 = "4c990c0416af1a4b657cd722e32a09ea"
2025-07-24 21:05:25.108720 [INFO] mod_signalwire.c:1129 Received configuration from SignalWire
```
This is good.  Next check the SIP stack:
```
jkozik@u2004:~/projects/freeswitchsignalwire2025$ docker exec -it freeswitch  sh -c "fs_cli -x 'sofia status'"
                     Name          Type                                       Data      State
=================================================================================================
            external-ipv6       profile                   sip:mod_sofia@[::1]:5080      RUNNING (0)
               signalwire       profile          sip:mod_sofia@69.243.158.102:6050      RUNNING (0) (TLS)
   signalwire::signalwire       gateway   sip:caca1ddb40128438e53cb875f3faad0e@jkozik-63eecb1e59a343e4b71567f323a71d52.sip.signalwire.com       REGED
          192.168.100.128         alias                                   internal      ALIASED
                 external       profile          sip:mod_sofia@69.243.158.102:5080      RUNNING (0)
    external::example.com       gateway                    sip:joeuser@example.com      NOREG
            internal-ipv6       profile                   sip:mod_sofia@[::1]:5060      RUNNING (0)
                 internal       profile          sip:mod_sofia@69.243.158.102:5060      RUNNING (0)
=================================================================================================
5 profiles 1 alias
```
Note:  It is just like the previous stack with addition of the `signalwire::signalwire` gateway.  Note:  is it `REGED`. The example.com gateway is still in there.  I try to ignore it. It is `NOREG`

## Check Mobile phone to 1001 cient
The way Signalwire works, the phone number that I bought maps to the client 1001. So on my mobile, I dial 630-387-XXXX, Signalwire receives it and creates a SIP INVITE to my Freeswitch. Here's the incoming SIP call flow:
<img width="1337" height="521" alt="image" src="https://github.com/user-attachments/assets/64e9707c-9698-4b13-ad57-32052658aa6b" />

## Check 1001 call to my mobile phone
Like the previous call, it gets routed from my Freeswitch to the Signalwire server that then completes the call to my mobile phone 630-215-XXXX.
<img width="1343" height="564" alt="image" src="https://github.com/user-attachments/assets/cbcf6ebf-d14d-4031-8a46-382e25c3a0c6" />

# Summary
Thanks to the [`safarov/freeswitch`](https://hub.docker.com/r/safarov/freeswitch) image and thanks to [Omid's video](https://www.youtube.com/watch?v=ax1uL4Z9Nao&t=63s), the  Freeswitch/Signalwire connector setup is realitively easy to setup.  I am attending the upcoming Cluecon conference and I'll ask if there's an official image and docker-compose.yaml file that I should use.

# References 
- Docker image [`safarov/freeswitch`](https://hub.docker.com/r/safarov/freeswitch)
- [mod_signalwire](https://developer.signalwire.com/freeswitch/FreeSWITCH-Explained/Modules/mod_signalwire_19595544/#3-dialplan-sample) documentation
- [Learn FreeSWITCH (Part8) - SignalWire Connector](https://www.youtube.com/watch?v=ax1uL4Z9Nao&t=63s)


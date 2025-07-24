# Freeswitch docker container linked to Signalwire 2025
I went to [docker hub](https://hub.docker.com/) and [searched for freeswitch](https://hub.docker.com/search?q=freeswitch).  I was looking for the office docker image.  I found dozens of them.  Unsure of which one to pick, I decided to base this project on [`safarov/freeswitch`](https://hub.docker.com/r/safarov/freeswitch).  It has over 1M downloads, and was only 2 months old.  Someday, I'll learn the official docker image release process.

<img width="532" height="387" alt="image" src="https://github.com/user-attachments/assets/bffcea07-dcc6-4f6e-8d49-c4e5aae7b632" />

What I wanted to do was run a freeswitch container on my home LAN and connect it to Signalwire.  I wanted to a setup that was a push button as possible.  

## Here's my target architecture:
<img width="900" height="512" alt="image" src="https://github.com/user-attachments/assets/9bff192a-5dac-4060-bd6f-9296324a5358" />

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

The image safarov/freeswitch is used as is.  Its docker hub suggests usage.  I wrote the docker compose file based on those notes.

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
Here's the first 100 lines of  the freeswitch container boots log.
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
2025-07-24 02:54:09.267673 [NOTICE] switch_loadable_module.c:412 Adding API Function 'cdr_csv'
2025-07-24 02:54:09.268120 [CONSOLE] switch_loadable_module.c:1803 Successfully Loaded [mod_event_socket]
2025-07-24 02:54:09.268146 [NOTICE] switch_loadable_module.c:350 Adding Application 'socket'
2025-07-24 02:54:09.268172 [NOTICE] switch_loadable_module.c:412 Adding API Function 'event_sink'
2025-07-24 02:54:09.270206 [INFO] mod_sofia.c:6247 Starting initial message thread.
2025-07-24 02:54:09.270314 [DEBUG] sofia.c:4628 debug [0]
2025-07-24 02:54:09.270328 [DEBUG] sofia.c:4628 sip-trace [no]
2025-07-24 02:54:09.270333 [DEBUG] sofia.c:4628 sip-capture [no]
2025-07-24 02:54:09.270335 [DEBUG] sofia.c:4628 rfc2833-pt [101]
2025-07-24 02:54:09.270343 [DEBUG] sofia.c:4628 sip-port [5080]
2025-07-24 02:54:09.270350 [DEBUG] sofia.c:4628 dialplan [XML]
2025-07-24 02:54:09.270360 [DEBUG] sofia.c:4628 context [public]
2025-07-24 02:54:09.270365 [DEBUG] sofia.c:4628 dtmf-duration [2000]
2025-07-24 02:54:09.270370 [DEBUG] sofia.c:4628 inbound-codec-prefs [OPUS,G722,PCMU,PCMA,H264,VP8]
2025-07-24 02:54:09.270378 [DEBUG] sofia.c:4628 outbound-codec-prefs [OPUS,G722,PCMU,PCMA,H264,VP8]
2025-07-24 02:54:09.270383 [DEBUG] sofia.c:4628 hold-music [local_stream://moh]
2025-07-24 02:54:09.270389 [DEBUG] sofia.c:4628 rtp-timer-name [soft]
2025-07-24 02:54:09.270393 [DEBUG] sofia.c:4628 local-network-acl [localnet.auto]
2025-07-24 02:54:09.270397 [DEBUG] sofia.c:4628 manage-presence [false]
2025-07-24 02:54:09.270402 [DEBUG] sofia.c:4628 inbound-codec-negotiation [generous]
2025-07-24 02:54:09.270408 [DEBUG] sofia.c:4628 nonce-ttl [60]
2025-07-24 02:54:09.270415 [DEBUG] sofia.c:4628 auth-calls [false]
2025-07-24 02:54:09.270422 [DEBUG] sofia.c:4628 inbound-late-negotiation [true]
2025-07-24 02:54:09.270425 [DEBUG] sofia.c:4628 inbound-zrtp-passthru [true]
2025-07-24 02:54:09.270428 [DEBUG] sofia.c:4628 rtp-ip [::1]
2025-07-24 02:54:09.270433 [DEBUG] sofia.c:4628 sip-ip [::1]
2025-07-24 02:54:09.270436 [DEBUG] sofia.c:4628 rtp-timeout-sec [300]
2025-07-24 02:54:09.270440 [WARNING] sofia.c:5227 rtp-timeout-sec deprecated use media_timeout variable.
2025-07-24 02:54:09.270442 [DEBUG] sofia.c:4628 rtp-hold-timeout-sec [1800]
2025-07-24 02:54:09.270448 [WARNING] sofia.c:5234 rtp-hold-timeout-sec deprecated use media_hold_timeout variable.
2025-07-24 02:54:09.270450 [DEBUG] sofia.c:4628 tls [false]
2025-07-24 02:54:09.270457 [DEBUG] sofia.c:4628 tls-only [false]
2025-07-24 02:54:09.270464 [DEBUG] sofia.c:4628 tls-bind-params [transport=tls]
2025-07-24 02:54:09.270469 [DEBUG] sofia.c:4628 tls-sip-port [5081]
2025-07-24 02:54:09.270475 [DEBUG] sofia.c:4628 tls-passphrase []
2025-07-24 02:54:09.270481 [DEBUG] sofia.c:4628 tls-verify-date [true]
2025-07-24 02:54:09.270486 [DEBUG] sofia.c:4628 tls-verify-policy [none]
2025-07-24 02:54:09.270502 [DEBUG] sofia.c:4628 tls-verify-depth [2]
2025-07-24 02:54:09.270510 [DEBUG] sofia.c:4628 tls-verify-in-subjects []
2025-07-24 02:54:09.270516 [DEBUG] sofia.c:4628 tls-version [tlsv1,tlsv1.1,tlsv1.2]
2025-07-24 02:54:09.270525 [INFO] sofia.c:6028 Setting MAX Auth Validity to 0 Attempts
2025-07-24 02:54:09.270613 [NOTICE] sofia.c:6195 Started Profile external-ipv6 [sofia_reg_external-ipv6]
2025-07-24 02:54:09.270708 [DEBUG] sofia.c:4628 debug [0]
2025-07-24 02:54:09.270714 [DEBUG] sofia.c:4628 sip-trace [no]
2025-07-24 02:54:09.270716 [DEBUG] sofia.c:4628 sip-capture [no]
2025-07-24 02:54:09.270718 [DEBUG] sofia.c:4628 rfc2833-pt [101]
2025-07-24 02:54:09.270722 [DEBUG] sofia.c:4628 sip-port [5080]
2025-07-24 02:54:09.270727 [DEBUG] sofia.c:4628 dialplan [XML]
2025-07-24 02:54:09.270732 [DEBUG] sofia.c:4628 context [public]
2025-07-24 02:54:09.270736 [DEBUG] sofia.c:4628 dtmf-duration [2000]
2025-07-24 02:54:09.270743 [DEBUG] sofia.c:4628 inbound-codec-prefs [OPUS,G722,PCMU,PCMA,H264,VP8]
2025-07-24 02:54:09.270747 [DEBUG] sofia.c:4628 outbound-codec-prefs [OPUS,G722,PCMU,PCMA,H264,VP8]
2025-07-24 02:54:09.270751 [DEBUG] sofia.c:4628 hold-music [local_stream://moh]
2025-07-24 02:54:09.270756 [DEBUG] sofia.c:4628 rtp-timer-name [soft]
2025-07-24 02:54:09.270760 [DEBUG] sofia.c:4628 local-network-acl [localnet.auto]
2025-07-24 02:54:09.270765 [DEBUG] sofia.c:4628 manage-presence [false]
2025-07-24 02:54:09.270770 [DEBUG] sofia.c:4628 inbound-codec-negotiation [generous]
2025-07-24 02:54:09.270773 [DEBUG] sofia.c:4628 nonce-ttl [60]
2025-07-24 02:54:09.270777 [DEBUG] sofia.c:4628 auth-calls [false]
2025-07-24 02:54:09.270780 [DEBUG] sofia.c:4628 inbound-late-negotiation [true]
2025-07-24 02:54:09.270783 [DEBUG] sofia.c:4628 inbound-zrtp-passthru [true]
2025-07-24 02:54:09.270785 [DEBUG] sofia.c:4628 rtp-ip [192.168.100.128]
2025-07-24 02:54:09.270788 [DEBUG] sofia.c:4628 sip-ip [192.168.100.128]
2025-07-24 02:54:09.270791 [DEBUG] sofia.c:4628 ext-rtp-ip [69.243.158.102]
2025-07-24 02:54:09.270794 [DEBUG] sofia.c:4628 ext-sip-ip [69.243.158.102]
2025-07-24 02:54:09.270798 [DEBUG] sofia.c:4628 rtp-timeout-sec [300]
2025-07-24 02:54:09.270801 [WARNING] sofia.c:5227 rtp-timeout-sec deprecated use media_timeout variable.
2025-07-24 02:54:09.270804 [DEBUG] sofia.c:4628 rtp-hold-timeout-sec [1800]
2025-07-24 02:54:09.270806 [WARNING] sofia.c:5234 rtp-hold-timeout-sec deprecated use media_hold_timeout variable.
2025-07-24 02:54:09.270808 [DEBUG] sofia.c:4628 tls [false]
2025-07-24 02:54:09.270812 [DEBUG] sofia.c:4628 tls-only [false]
2025-07-24 02:54:09.270825 [DEBUG] sofia.c:4628 tls-bind-params [transport=tls]
2025-07-24 02:54:09.270830 [DEBUG] sofia.c:4628 tls-sip-port [5081]
2025-07-24 02:54:09.270828 [DEBUG] sofia.c:3158 Creating agent for external-ipv6
2025-07-24 02:54:09.270835 [DEBUG] sofia.c:4628 tls-passphrase []
2025-07-24 02:54:09.270840 [DEBUG] sofia.c:4628 tls-verify-date [true]
2025-07-24 02:54:09.270847 [DEBUG] sofia.c:4628 tls-verify-policy [none]
2025-07-24 02:54:09.270852 [DEBUG] sofia.c:4628 tls-verify-depth [2]
2025-07-24 02:54:09.270856 [DEBUG] sofia.c:4628 tls-verify-in-subjects []
2025-07-24 02:54:09.270860 [DEBUG] sofia.c:4628 tls-version [tlsv1,tlsv1.1,tlsv1.2]
2025-07-24 02:54:09.270869 [INFO] sofia.c:6028 Setting MAX Auth Validity to 0 Attempts
2025-07-24 02:54:09.270938 [NOTICE] sofia.c:6195 Started Profile external [sofia_reg_external]
2025-07-24 02:54:09.271034 [DEBUG] sofia.c:4628 debug [0]
2025-07-24 02:54:09.271038 [DEBUG] sofia.c:4628 sip-trace [no]
2025-07-24 02:54:09.271041 [DEBUG] sofia.c:4628 context [public]
2025-07-24 02:54:09.271045 [DEBUG] sofia.c:4628 rfc2833-pt [101]
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
- RTP Ports.  My home network has multiple VoIP services.  I want Freeswitch to use a very specific ranges of ports.  This reflects in my firewall settings and the switch.conf.xml file.
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
### Client 1001 calls cliet 1002
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
Take that token to Signalwire->Integrations, "Connect to Freeswitch" on my signalwire.com portal.  Create a connection and link it to my signalwire phone number 630-387-XXXX.

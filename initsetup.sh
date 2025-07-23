#!/bin/sh
set -a
source ./.env
if [ ! -f container_initialized ]; then
    # Your one-time init logic here
    echo "enter initsetup.sh"
    #docker exec -it freeswitch sed -i -e '/^<!--/! s/default_password=.*\"/default_password=12345\"/' \
         #/etc/freeswitch/vars.xml

    docker exec -it freeswitch sed -i -e "/^<!--/! s/default_password=.*\"/default_password=${FREESWITCHDEFAULTPASSWORD}\"/" \
        /etc/freeswitch/vars.xml    

    docker cp 01_aaSignalWirePSTN.xml freeswitch:/etc/freeswitch/dialplan/default/
    docker cp 01_abSignalWireIncomingFromPSTN.xml freeswitch:/etc/freeswitch/dialplan/default/

    docker exec -it freeswitch sed -i -e "/destination_number/s/expression=\".*\"/expression=\"\^\(\\\\${MYSIGNALWIREPHONENUMBERWITHPLUS}\)\$\"/" \
    /etc/freeswitch/dialplan/default/01_abSignalWireIncomingFromPSTN.xml 

    docker exec -it freeswitch sed -i '/RTP port range/a\
<param name=\"rtp-start-port\" value=\"rtpstart\"/>\
<param name=\"rtp-end-port\" value=\"rtpend\"/>\

' /etc/freeswitch/autoload_configs/switch.conf.xml

    docker exec -it freeswitch sed -i -e "s/rtpstart/${RTPSTARTPORT}/" \
                                      -e "s/rtpend/${RTPENDPORT}/" \
        /etc/freeswitch/autoload_configs/switch.conf.xml  
    EXTV6=/etc/freeswitch/sip_profiles/external-ipv6.xml
    INTV6=/etc/freeswitch/sip_profiles/internal-ipv6.xml
    docker exec -it freeswitch sh -c "if [ -f $EXTV6 ]; then mv $EXTV6 $EXTV6.inactive;fi"              
    docker exec -it freeswitch sh -c "if [ -f $INTV6 ]; then mv $INTV6 $INTV6.inactive;fi"


    

    #i#touch container_initialized
fi


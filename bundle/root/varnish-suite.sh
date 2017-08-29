#/bin/bash
set -e

if [ -z "${SINGLE}" -o "${SINGLE}" = "varnish" ]; then
	echo starting varnishd
	VARNISH_STORAGE=${VARNISH_STORAGE:-"malloc,256MB"}
	varnishd \
		${SINGLE/varnish/-F} \
		-a :80 \
		-a :8443,PROXY \
		-f /etc/varnish/default.vcl \
		-s ${VARNISH_STORAGE} \
		${VARNISH_OPTS}
fi

if [ -z "${SINGLE}" -o "${SINGLE}" = "hitch" ]; then
	echo starting hitch
	mkdir -p /var/lib/hitch-ocsp
	if [ -z "${SINGLE}" ]; then
		DAEMON="--daemon --backend=[127.0.0.1]:8443";
	fi
	echo ${DAEMON}
	hitch \
		--config=/etc/hitch/hitch.conf \
		${DAEMON} \
		${HITCH_OPTIONS}
fi

if [ -z "${SINGLE}" -o "${SINGLE}" = "agent" ]; then
	echo waiting for the VSM to be up
	echo varnishstat -1 ${STAT_OPTS}
	while ! varnishstat -1 ${STAT_OPTS} &> /dev/null; do sleep 1; done
	echo starting varnish-agent
	varnish-agent \
		-K /etc/varnish/agent_secret \
		${SINGLE/agent/-d} \
		${AGENT_OPTS}
fi

if [ -z "${SINGLE}" ]; then 
	echo done
	tail -f /dev/null
fi

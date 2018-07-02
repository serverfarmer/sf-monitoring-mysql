#!/bin/sh

/opt/farm/scripts/setup/extension.sh sf-monitoring-newrelic
/opt/farm/scripts/setup/extension.sh sf-db-utils

if [ ! -s /etc/local/.config/newrelic.license ]; then
	echo "skipping newrelic-mysql-plugin configuration (no license key configured)"
	exit 0
elif [ "`which java`" = "" ]; then
	/opt/farm/scripts/setup/extension.sh sf-java8
fi

/opt/farm/ext/packages/utils/install.sh sudo

/opt/farm/ext/monitoring-mysql/setup-plugin.sh

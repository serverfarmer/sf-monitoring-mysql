#!/bin/sh
. /opt/farm/ext/db-utils/functions.mysql

mysqluser=`mysql_local_user`
mysqlpass=`mysql_local_password`

if [ "$mysqluser" = "" ]; then
	echo "skipping newrelic-mysql-plugin configuration (no mysql-server detected)"
	exit 0
fi

path=/opt/newrelic
mkdir -p $path

VERSION="2.0.0"
LOCAL="newrelic_mysql_plugin-$VERSION"

if [ ! -d $path/mysql ]; then
	cd $path
	wget "https://github.com/newrelic-platform/newrelic_mysql_java_plugin/raw/master/dist/$LOCAL.tar.gz"
	tar xzf $LOCAL.tar.gz
	rm -f $LOCAL.tar.gz
	mv $LOCAL mysql
	cd mysql

	license="`cat /etc/local/.config/newrelic.license`"

	cat $path/mysql/config/newrelic.template.json |sed s/YOUR_LICENSE_KEY_HERE/$license/g >$path/mysql/config/newrelic.json
	cat $path/mysql/config/plugin.template.json |sed \
		-e s/USER_NAME_HERE/$mysqluser/g \
		-e s/USER_PASSWD_HERE/$mysqlpass/g \
		-e s/Localhost/`hostname`/g \
		>$path/mysql/config/plugin.json
	chmod 0600 $path/mysql/config/*.json

	echo "#!/bin/sh\n\ncd $path/mysql && sudo -b -u newrelic java -Xmx128m -jar plugin.jar >>plugin.log" >$path/mysql/start.sh
	touch $path/mysql/plugin.log
	chmod +x $path/mysql/start.sh
	chown -R newrelic:newrelic $path/mysql

	$path/mysql/start.sh
	echo "newrelic-mysql-plugin successfully installed"
fi

if [ "`cat /etc/rc.local /etc/local/*.sh 2>/dev/null |grep $path/mysql/start.sh`" = "" ]; then
	echo "##############################################################################"
	echo "# now add $path/mysql/start.sh script to your preferred boot trigger #"
	echo "##############################################################################"
fi

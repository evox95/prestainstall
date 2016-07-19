#!/bin/bash 

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root" 1>&2;
	exit 1;
fi

showStepNumber () {

	echo -n "[${1}/7] "

}

showStep () {

	step=$1

	showTitle;

	if [ $step -ge 1 ]; then
	showStepNumber 1
	echo -n "Getting required data... ";
	fi

	if [ $step -ge 2 ]; then
	echo "OK";
	showStepNumber 2
	echo -n "Downloading files... ";
	fi

	if [ $step -ge 3 ]; then
	echo "OK";
	showStepNumber 3
	echo -n "Extracting files... ";
	fi

	if [ $step -ge 4 ]; then
	echo "OK";
	showStepNumber 4
	echo -n "Creating database... ";
	fi

	if [ $step -ge 5 ]; then
	echo "OK";
	showStepNumber 5
	echo -n "Changing permissions... ";
	fi

	if [ $step -ge 6 ]; then
	echo "OK";
	showStepNumber 6
	echo -n "Installing PrestaShop... ";
	fi

	if [ $step -ge 7 ]; then
	echo "OK";
	showStepNumber 7
	echo -n "Removing installation files... ";
	fi

	if [ $step -gt 7 ]; then
	echo "OK";
	echo "Instalation completed!";
	fi

}

showTitle () {

	clear;
	echo "PRESTASHOP 1.6 FAST INSTALLER <contact@bestcoding.net>";
	echo "------------------------------------------------------";
	echo;

}

runInstaller () {

	package='prestashop_1.6.1.6_pl'
	pwd_=`pwd`;

	showStep 2;
	echo;
	wget "https://download.prestashop.com/download/releases/${package}.zip" -O "${package}.zip";

	showStep 3;
	mkdir "./${newname}";
	unzip -q "${package}.zip" -d "./${newname}";
	mv ./${newname}/prestashop/* "./${newname}";
	rm "${package}.zip";

	showStep 4;
	echo "CREATE DATABASE ${newname}" | mysql -u$db_user -p$db_pass -s;

	showStep 5;
	chmod -R 775 ./${newname}/cache
	chmod -R 775 ./${newname}/cache/cachefs
	chmod -R 775 ./${newname}/cache/smarty
	chmod -R 775 ./${newname}/cache/smarty/cache
	chmod -R 775 ./${newname}/cache/smarty/compile
	chmod -R 775 ./${newname}/cache/tcpdf
	chmod -R 775 ./${newname}/classes
	chmod -R 775 ./${newname}/config
	chmod -R 775 ./${newname}/config/xml
	chmod -R 775 ./${newname}/controllers
	chmod -R 775 ./${newname}/css
	chmod -R 775 ./${newname}/docs
	chmod -R 775 ./${newname}/download
	chmod -R 775 ./${newname}/img
	chmod -R 775 ./${newname}/js
	chmod -R 775 ./${newname}/localization
	chmod -R 775 ./${newname}/log
	chmod -R 775 ./${newname}/mails
	chmod -R 775 ./${newname}/modules
	chmod -R 775 ./${newname}/override
	chmod -R 775 ./${newname}/pdf
	chmod -R 775 ./${newname}/themes/*/cache
	chmod -R 775 ./${newname}/themes/*/lang
	chmod -R 775 ./${newname}/translations
	chmod -R 775 ./${newname}/upload
	chmod -R 775 ./${newname}/webservices
	chown -R www-data:www-data ./${newname}

	showStep 6;
	php "./${newname}/install/index_cli.php" --domain="${domain}" --db_server="${db_host}" --db_name="${db_name}" --db_user="${db_user}" --db_password="${db_pass}" --email="${admin_email}";
	echo "UPDATE ${newname}.ps_shop_url SET physical_uri = '${physical_uri}' WHERE id_shop_url = 1" | mysql -u$db_user -p$db_pass -s;

	showStep 7;
	rm -Rf "./${newname}/install";

	showStep 8;

	echo "------------------------------------------------------";
	echo "Installation directory: ${pwd_}/${newname}";
	echo;
	echo "Your shop available at: http://${domain}${physical_uri}";
	echo;
	echo "Your admin panel available at: http://${domain}${physical_uri}admin/";
	echo "Admin email: ${admin_email}";
	echo "Admin pass: 0123456789";
	echo;

}


showStep 1;
echo;

pwd_=`pwd`;

echo -n "Enter directory name to install PrestaShop: ${pwd_}/";
read -r newname;

echo -n "Enter domain: http://";
read -r domain;

echo -n "Enter physical uri: http://${domain}";
read -r physical_uri;

echo -n "Enter admin e-mail: ";
read -r admin_email;

echo -n "Enter database host: ";
read -r db_host;

echo -n "Enter database name: ";
read -r db_name;

echo -n "Enter database user: ";
read -r db_user;

echo -n "Enter database pass(hidden): ";
read -rs db_pass;

runInstaller;

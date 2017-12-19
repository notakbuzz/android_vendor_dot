#!/bin/bash

device=$(echo $TARGET_PRODUCT | cut -d _ -f 2,3)
echo ".................................."
echo "....Generating OTA for $device...."
echo ".................................."
start_dir=`pwd`

if [ -f $start_dir/*.xml ]; then
	rm $start_dir/*.xml
fi

cp vendor/dot/ota.xml $start_dir/$device.xml

touch $start_dir/$device.xml

DOT_OTA_MD5=$(cat "$OUT/${DOT_TARGET_PACKAGE}.md5sum" | cut -d ' ' -f 1)
DOT_OTA_FILESIZE=$(ls -la "$OUT/${DOT_TARGET_PACKAGE}" | cut -d ' ' -f 5)
DOT_OTA_ROM=dot_"$device"
DOT_OTA_VERNUM=$(date +%Y%m%d)
DOT_OTA_URL=https://sourceforge.net/projects/dotos-ota/files/$device/${DOT_TARGET_PACKAGE}
DOT_HTTP_URL=https://sourceforge.net/projects/dotos-ota/files/$device

sed -i "s/DOT_OTA_ROM/$DOT_OTA_ROM/g" $start_dir/$device.xml
sed -i "s/DOT_OTA_VERSION/${DOT_VERSION}/g" $start_dir/$device.xml
sed -i "s/DOT_OTA_VERNUM/$DOT_OTA_VERNUM/g" $start_dir/$device.xml
sed -i "s|DOT_OTA_URL|$DOT_OTA_URL|g" $start_dir/$device.xml
sed -i "s|DOT_HTTP_URL|$DOT_HTTP_URL|g" $start_dir/$device.xml
sed -i "s/DOT_OTA_MD5/DOT_OTA_MD5/g" $start_dir/$device.xml
sed -i "s/DOT_OTA_FILESIZE/DOT_OTA_FILESIZE/g" $start_dir/$device.xml

push() {
        cd ${ANDROID_BUILD_TOP}/ota
	git reset --hard HEAD
	git clean -f
	git pull
	cp $start_dir/$device.xml ${ANDROID_BUILD_TOP}/ota/$device.xml
        git add -A
        git commit -m "$device: weekly update ($(date +'%d/%m/%Y'))"
        git push --force origin dot-n
	cd ${ANDROID_BUILD_TOP}

	if [ $? -ne 0 ]; then
		echo "Failed to push xml!!"
		cd ${ANDROID_BUILD_TOP}
	fi
}

if [ -d ${ANDROID_BUILD_TOP}/ota ]; then
	push
else
	cd ${ANDROID_BUILD_TOP}
	git clone git@github.com:DotOS/services_apps_ota.git ota
	push
fi

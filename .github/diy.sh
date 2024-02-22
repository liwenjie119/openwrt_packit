#!/bin/bash

cd lede

function merge_package(){
    repo=`echo $1 | rev | cut -d'/' -f 1 | rev`
    pkg=`echo $2 | rev | cut -d'/' -f 1 | rev`
    # find package/ -follow -name $pkg -not -path "package/custom/*" | xargs -rt rm -rf
    git clone --depth=1 --single-branch $1
    mv $2 package/myapp/
    rm -rf $repo
}
rm -rf package/myapp; mkdir package/myapp


git clone https://github.com/kongfl888/luci-app-adguardhome package/myapp/luci-app-adguardhome
git clone https://github.com/2512500960/zzu-minieap-openwrt package/myapp/zzu-minieap-openwrt
#git clone https://github.com/tty228/luci-app-serverchan package/myapp/luci-app-serverchan
git clone https://github.com/yaof-project/luci-app-ikoolproxy package/myapp/luci-app-ikoolproxy
git clone https://github.com/destan19/OpenAppFilter.git package/myapp/OpenAppFilter
#rm -rf package/lean/luci-app-cpufreq
#tar zxf ../.github/luci-app-cpufreq-modified.tar.gz -C package/lean
#git clone https://github.com/tuanqing/install-program package/myapp/install-program
# helloworld&&lienol
sed -i '$a src-git helloworld https://github.com/fw876/helloworld;main' feeds.conf.default
#sed -i '$a src-git lienol https://github.com/Lienol/openwrt-package' feeds.conf.default
#svn co https://github.com/Lienol/openwrt-package/trunk/luci-app-ssr-mudb-server package/myapp/luci-app-ssr-mudb-server
merge_package https://github.com/Lienol/openwrt-package openwrt-package/luci-app-ssr-mudb-server
#svn co https://github.com/messense/aliyundrive-webdav/trunk/openwrt package/myapp/aliyundrive-webdav
#晶晨宝盒
#svn co https://github.com/ophub/luci-app-amlogic/trunk/luci-app-amlogic package/luci-app-amlogic
merge_package https://github.com/ophub/luci-app-amlogic luci-app-amlogic/luci-app-amlogic
sed -i "s|https.*/OpenWrt|https://github.com/liwenjie119/openwrt_packit|g" package/myapp/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|ARMv8|arm|g" package/myapp/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|opt/kernel|https://github.com/breakings/OpenWrt/tree/main/opt/kernel|g" package/myapp/luci-app-amlogic/root/etc/config/amlogic

# replace antfs 
sed -i 's/antfs-mount/ntfs-3g/g' ./package/lean/automount/Makefile

#luci-theme-argon
rm -rf package/lean/luci-theme-argon  
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/lean/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config package/myapp/luci-app-argon-config

./scripts/feeds update -a
./scripts/feeds install -a
#sed -i '34 s/$/ +libselinux +libsepol/' feeds/packages/utils/lvm2/Makefile
#sed -i '34 s/$/ +libselinux/' feeds/packages/utils/vim/Makefile
#sed -i 's/luci-lib-ipkg/luci-base/g' package/feeds/helloworld/luci-app-ssr-plus/Makefile
sed -i '/FEATURES+=/ { s/cpiogz //; s/ext4 //; s/ramdisk //; s/squashfs //; }' target/linux/armvirt/Makefile

#临时修改修复
sed -i 's/stripped/release/g' feeds/packages/multimedia/aliyundrive-webdav/Makefile
sed -i "70 s/$/ -D_LARGEFILE64_SOURCE/" feeds/packages/utils/xfsprogs/Makefile

sed -i '$d' target/linux/armvirt/image/Makefile
echo -e 'define Device/Phicomm-n1
DEVICE_MODEL := Phicomm-n1
  DEVICE_PACKAGES := \
	perl perlbase-base perbase-file perl-http-date perlbase-getopt perlbase-time perlbase-unicode perlbase-utf8 \
	blkid fdisk lsblk parted \
	attr btrfs-progs chattr dosfstools e2fsprogs f2fs-tools f2fsck lsattr mkf2fs xfs-fsck xfs-mkfs \
	bsdtar pigz \
	bash \
	gawk getopt losetup tar uuidgen bzip2 vim \
	acpid \
	kmod-brcmfmac kmod-brcmutil kmod-cfg80211 kmod-mac80211 hostpad-common iw wpa-cli wpad-openssl \
	kmod-fs-ext4 kmod-fs-vfat kmod-fs-exfat libzstd \
	kmod-usb-storage kmod-usb-storage-extras kmod-usb-storage-uas \
	kmod-usb-net kmod-usb-net-asix-ax88179 kmod-usb-net-rtl8150 kmod-usb-net-rtl8152 \
	libattr  cfdisk  resize2fs tune2fs pv unzip \
	lscpu htop iperf3 curl lm-sensors 
endef
ifeq ($(SUBTARGET),64)
  TARGET_DEVICES += Phicomm-n1
endif\n
$(eval $(call BuildImage))' >> ./target/linux/armvirt/image/Makefile

cp ../.github/n1.config .config 
echo -e 'CONFIG_DEVEL=y\nCONFIG_CCACHE=y' >> .config; make defconfig



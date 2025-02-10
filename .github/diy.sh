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

git clone https://github.com/2512500960/zzu-minieap-openwrt package/myapp/zzu-minieap-openwrt
git clone https://github.com/tty228/luci-app-wechatpush package/myapp/luci-app-wechatpush
git clone https://github.com/yaof2/luci-app-ikoolproxy package/myapp/luci-app-ikoolproxy
git clone https://github.com/destan19/OpenAppFilter.git package/myapp/OpenAppFilter
# helloworld&&lienol
sed -i '$a src-git helloworld https://github.com/fw876/helloworld;master' feeds.conf.default
#sed -i '$a src-git lienol https://github.com/Lienol/openwrt-package' feeds.conf.default


#晶晨宝盒
merge_package https://github.com/ophub/luci-app-amlogic luci-app-amlogic/luci-app-amlogic
sed -i "s|https.*/OpenWrt|https://github.com/liwenjie119/openwrt_packit|g" package/myapp/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|ARMv8|arm|g" package/myapp/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|opt/kernel|https://github.com/breakingbadboy/OpenWrt/tree/main/opt/kernel|g" package/myapp/luci-app-amlogic/root/etc/config/amlogic



./scripts/feeds update -a
./scripts/feeds install -a
sed -i '/FEATURES+=/ { s/cpiogz //; s/ext4 //; s/ramdisk //; s/squashfs //; }' target/linux/armvirt/Makefile


#临时修改修复
#sed -i 's/stripped/release/g' feeds/packages/multimedia/aliyundrive-webdav/Makefile
#sed -i "70 s/$/ -D_LARGEFILE64_SOURCE/" feeds/packages/utils/xfsprogs/Makefile

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


./scripts/diffconfig.sh > seed1.config
cat .config

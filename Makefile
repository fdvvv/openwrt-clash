include $(TOPDIR)/rules.mk

PKG_NAME:=clash
PKG_VERSION:=1.11.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/Dreamacro/clash/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=ca57b55b25bdd035df2f7baaee33e869153df55f693c452261fc91c819554c21

PKG_MAINTAINER:=Chandelure Wang <me@chandelure.com>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/clash-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1

GO_PKG:=github.com/Dreamacro/clash
GO_PKG_BUILD_PKG:=$(GO_PKG)
GO_PKG_LDFLAGS_X:= \
	$(GO_PKG)/constant.Version=$(PKG_VERSION) 

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/../feeds/packages/lang/golang/golang-package.mk

define Package/$(PKG_NAME)/template
	SECTION:=net
	CATEGORY:=Network
endef

define Package/$(PKG_NAME)
	$(call Package/$(PKG_NAME)/template)
	TITLE:=A rule-based tunnel in Go
	URL:=https://github.com/dreamacro/clash
	DEPENDS:=$(GO_ARCH_DEPENDS) \
		+iptables \
		+iptables-mod-tproxy \
		+libuci-lua \
		+lyaml \
		+ca-bundle
endef

YACD_DASHBOARD_VER=0.3.6

define Package/clash-dashboard
	$(call Package/$(PKG_NAME)/template)
	TITLE:=Web Dashboard for Clash
	URL:=https://github.com/dreamacro/clash-dashboard
	DEPENDS:=$(PKG_NAME)
	PKGARCH:=all
	VERSION:=$(YACD_DASHBOARD_VER)
endef

define Package/$(PKG_NAME)/description
	Clash, A rule based tunnel in Go, support VMess, Shadowsocks,
	Trojan, Snell protocol for remote connections.
endef

define Package/clash-dashboard/description
	Web Dashboard for Clash
endef

define Package/$(PKG_NAME)/config
	menu "Clash Counfiguration"
		depends on PACKAGE_$(PKG_NAME)
	
	config PACKAGE_CLASH_INCLUDE_COUNTRY_MMDB
		bool "Include Country.mmdb"
		default y

	endmenu
endef

define Package/$(PKG_NAME)/conffiles
/etc/clash/profiles/
/etc/config/clash
endef

COUNTRY_MMDB_VER=20220812
COUNTRY_MMDB_FILE:=Country.$(COUNTRY_MMDB_VER).mmdb

define Download/country_mmdb
	URL:=https://github.com/Dreamacro/maxmind-geoip/releases/download/$(COUNTRY_MMDB_VER)/
	URL_FILE:=Country.mmdb
	FILE:=$(COUNTRY_MMDB_FILE)
	HASH:=532a0c07ea092cfd25e4678ba4cb31e728e34634cc334582d65a245c6d85ab75
endef

define Download/clash-dashboard
	URL:=https://github.com/haishanh/yacd/releases/download/v$(YACD_DASHBOARD_VER)/
	URL_FILE:=yacd.tar.xz
	FILE:=yacd.tar.xz
	HASH:=608c7e21c1ee6cfee6268c5a3951a4c21dc407eea67049058cec299c0b11e2fb
endef

define Build/Prepare
	$(call Build/Prepare/Default)

ifdef CONFIG_PACKAGE_CLASH_INCLUDE_COUNTRY_MMDB
	$(call Download,country_mmdb)
endif

ifdef CONFIG_PACKAGE_clash-dashboard
	$(call Download,clash-dashboard)
endif

endef

define Package/$(PKG_NAME)/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/clash $(1)/usr/bin/clash

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(CURDIR)/files/clash.init $(1)/etc/init.d/clash

	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) $(CURDIR)/files/clash.conf $(1)/etc/config/clash

ifdef CONFIG_PACKAGE_CLASH_INCLUDE_COUNTRY_MMDB
	$(INSTALL_DIR) $(1)/etc/clash/
	$(INSTALL_DATA) $(DL_DIR)/$(COUNTRY_MMDB_FILE) $(1)/etc/clash/Country.mmdb
endif

	$(INSTALL_DIR) $(1)/usr/lib/clash/
	$(INSTALL_BIN) $(CURDIR)/files/create_rules.sh $(1)/usr/lib/clash/create_rules.sh
	$(INSTALL_BIN) $(CURDIR)/files/clear_rules.sh $(1)/usr/lib/clash/clear_rules.sh
	$(INSTALL_BIN) $(CURDIR)/files/build_conf.lua $(1)/usr/lib/clash/build_conf.lua
	$(INSTALL_BIN) $(CURDIR)/files/update_profile.sh $(1)/usr/lib/clash/update_profile.sh
endef

define Package/clash-dashboard/install
	$(INSTALL_DIR) $(1)/www/clash-dashboard/
	$(TAR) -C $(DL_DIR) -Jxvf $(DL_DIR)/yacd.tar.xz
	$(CP) \
		$(DL_DIR)/public/assets \
		$(DL_DIR)/public/index.html \
		$(DL_DIR)/public/registerSW.js \
		$(DL_DIR)/public/sw.js \
		$(DL_DIR)/public/yacd-128.png \
		$(DL_DIR)/public/yacd-64.png \
		$(DL_DIR)/public/yacd.ico \
		$(DL_DIR)/public/_headers \
		$(1)/www/clash-dashboard/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,clash-dashboard))

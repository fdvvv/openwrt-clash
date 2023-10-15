include $(TOPDIR)/rules.mk

PKG_NAME:=clash
PKG_VERSION:=1.16.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME).meta-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/MetaCubeX/Clash.Meta/archive/refs/tags/v$(PKG_VERSION)
PKG_HASH:=skip

PKG_MAINTAINER:=Chandelure Wang <me@chandelure.com>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/clash-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/MetaCubeX/Clash.Meta
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
	URL:=https://github.com/MetaCubeX/Clash.Meta
	DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/$(PKG_NAME)/description
	Clash, A rule based tunnel in Go, support VMess, Shadowsocks,
	Trojan, Snell protocol for remote connections.
endef

define Package/$(PKG_NAME)/config
	menu "Clash Counfiguration"
		depends on PACKAGE_$(PKG_NAME)

	endmenu
endef

define Package/$(PKG_NAME)/conffiles
/etc/clash/profiles/
/etc/config/clash
endef

define Build/Prepare
	$(call Build/Prepare/Default)

endef

define Package/$(PKG_NAME)/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/clash.meta $(1)/usr/bin/clash.meta

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(CURDIR)/files/clash.init $(1)/etc/init.d/clash

	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) $(CURDIR)/files/clash.conf $(1)/etc/config/clash


	$(INSTALL_DIR) $(1)/usr/lib/clash/
	$(INSTALL_BIN) $(CURDIR)/files/create_rules.sh $(1)/usr/lib/clash/create_rules.sh
	$(INSTALL_BIN) $(CURDIR)/files/clear_rules.sh $(1)/usr/lib/clash/clear_rules.sh
	$(INSTALL_BIN) $(CURDIR)/files/build_conf.lua $(1)/usr/lib/clash/build_conf.lua
	$(INSTALL_BIN) $(CURDIR)/files/update_profile.sh $(1)/usr/lib/clash/update_profile.sh
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

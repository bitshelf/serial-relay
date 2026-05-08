# Makefile for serial-relay
#   make          — build release binary
#   make deb      — build .deb package
#   make install  — install to /usr/local/bin
#   make clean    — remove build artifacts

.PHONY: all build deb install uninstall clean

all: build

build:
	cargo build --release

deb: build
	@PACKAGE_ROOT="deb-pkg/serial-relay_0.1.0_arm64"; \
	rm -rf deb-pkg/; \
	mkdir -p "$$PACKAGE_ROOT/DEBIAN" "$$PACKAGE_ROOT/usr/bin" \
	         "$$PACKAGE_ROOT/usr/share/doc/serial-relay"; \
	install -m 755 target/release/serial "$$PACKAGE_ROOT/usr/bin/serial"; \
	BAUD=$$(grep baud_rate Cargo.toml | head -1 | grep -oP '\d+'); \
	cat > "$$PACKAGE_ROOT/DEBIAN/control" <<CTRL
Package: serial-relay
Version: 0.1.0
Architecture: arm64
Maintainer: linaro <linaro@localhost>
Section: electronics
Priority: optional
Depends: libc6
Description: 4-channel USB relay controller (CH340)
 Control a 4-channel USB relay module over RS-232 serial via CH340.
 Supports on/off/toggle/status operations for each channel.
 Baud rate: $$BAUD
CTRL
	dpkg-deb --build "$$PACKAGE_ROOT" serial-relay_0.1.0_arm64.deb; \
	rm -rf deb-pkg/; \
	@echo "→ serial-relay_0.1.0_arm64.deb"

install: build
	sudo install -m 755 target/release/serial /usr/local/bin/serial

uninstall:
	sudo rm -f /usr/local/bin/serial

clean:
	cargo clean
	rm -f *.deb

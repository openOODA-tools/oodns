# ==============================================================================
# oodns: Sovereign DNS Resolver & Query Engine
# Verification, Build, Test, and Packaging Lifecycle Makefile
# ==============================================================================

SHELL := /bin/bash
BIN := dist/oodns
SRC := $(shell find . -name "*.oo" -not -path "./dist/*")
VERSION ?= 0.2.0

OODA_COMPILER ?= /home/ubermetroid/.openooda/bin/oodac
OODACODEX ?= /home/ubermetroid/.openooda/northstar.oot
OO_LIST_AMBIENT_QUOTA ?= 8589934592

.PHONY: all verify build test package clean check line-cap file-law academy density package-deb package-rpm package-arch

all: verify build test

$(BIN): $(SRC)
	@mkdir -p dist
	OO_LIST_AMBIENT_QUOTA=$(OO_LIST_AMBIENT_QUOTA) \
	OODACODEX=$(OODACODEX) \
	OODA_COMPILER=$(OODA_COMPILER) \
	OODA_NO_JAIL=1 \
	$(OODA_COMPILER) build main.oo -o $(BIN)
	@cp $(BIN) dist/oodns-linux-x86_64
	@cd dist && sha256sum oodns-linux-x86_64 > oodns-linux-x86_64.sha256
	@echo "built $(BIN) (and dist/oodns-linux-x86_64)"

build: $(BIN)

line-cap:
	@violations=0; \
	for f in $$(find . -name "*.oo" -o -name "*.oot" | grep -v '\.git' | grep -v 'dist/'); do \
		lines=$$(wc -l < "$$f"); \
		if grep -q '^// # ' "$$f" && [ $$lines -lt 16 ]; then \
			echo "VIOLATION: $$f has $$lines lines (< 16 floor)"; violations=$$((violations+1)); \
		fi; \
		if [ $$lines -gt 256 ]; then \
			echo "VIOLATION: $$f has $$lines lines (> 256 cap)"; violations=$$((violations+1)); \
		fi; \
	done; \
	if [ $$violations -gt 0 ]; then echo "FAIL: $$violations files violate line bounds"; exit 1; fi; \
	echo "PASS: Page Rule sizing (16-256 lines, shims exempt from floor) holds"

file-law:
	@bad=$$(find . -name "*.oo" | grep -E '(utils?|helpers?|common|misc|shared|base)\.oo$$' | grep -v 'dist/' || true); \
	if [ -n "$$bad" ]; then \
		echo "VIOLATION: Generic drawer filenames detected:"; echo "$$bad"; exit 1; \
	fi; \
	echo "PASS: file law holds"

academy:
	@missing=0; \
	for f in $$(find . -name "*.oo" -not -path "./dist/*"); do \
		hdr=$$(head -n 7 "$$f"); \
		for elem in "// # " "// Logline:" "// Setup:" "// Beats:"; do \
			if ! echo "$$hdr" | grep -qF "$$elem"; then \
				echo "VIOLATION: $$f missing '$$elem' in first 7 lines"; missing=$$((missing+1)); \
			fi; \
		done; \
	done; \
	if [ $$missing -gt 0 ]; then echo "FAIL: $$missing missing Academy header elements"; exit 1; fi; \
	echo "PASS: academy headers hold (all 4 elements present in first 7 lines)"

density:
	@violations=0; \
	for d in $$(find . -maxdepth 3 -type d -not -path '*/.*' -not -path './dist*' -not -path './packaging*'); do \
		n=$$(ls "$$d"/*.oo "$$d"/*.oot 2>/dev/null | grep -v '\*' | wc -l); \
		if [ $$n -gt 8 ]; then \
			echo "VIOLATION: $$d holds $$n pages (exceeds 8)"; violations=$$((violations+1)); \
		fi; \
	done; \
	if [ $$violations -gt 0 ]; then echo "FAIL: $$violations directories exceed the density bound"; exit 1; fi; \
	echo "PASS: directory density (<= 8 pages per directory) holds"

check:
	@for f in $$(find . -name "*.oo" -not -path "./dist/*"); do \
		OO_LIST_AMBIENT_QUOTA=$(OO_LIST_AMBIENT_QUOTA) OODACODEX=$(OODACODEX) OODA_COMPILER=$(OODA_COMPILER) OODA_NO_JAIL=1 $(OODA_COMPILER) check "$$f" > /dev/null || exit 1; \
	done; \
	echo "PASS: oodac check holds on all .oo files"

verify: line-cap file-law academy density check

test: $(BIN)
	@echo "=== testing --help ==="
	@./$(BIN) --help | grep -q "oodns" && echo "PASS: --help"
	@echo "=== testing --version ==="
	@./$(BIN) --version | grep -q "oodns" && echo "PASS: --version"
	@echo "=== testing internal anchors ==="
	@./$(BIN) --test | grep -q "PASSED" && echo "PASS: internal anchors"
	@echo "=== testing --demo ==="
	@./$(BIN) -D | grep -q "DNS Resolution Showcase" && echo "PASS: --demo"
	@echo "=== testing --demo --json ==="
	@./$(BIN) -D -j | grep -q '"domain"' && echo "PASS: --demo -j"
	@echo "=== testing query lookup ==="
	@./$(BIN) openooda.org A | grep -q "openooda.org" && echo "PASS: query lookup"
	@echo "=== testing short mode +short ==="
	@./$(BIN) openooda.org A +short | grep -q "185.199." && echo "PASS: +short"
	@echo "=== testing reverse lookup -x ==="
	@./$(BIN) -x 1.1.1.1 | grep -q "one.one.one.one" && echo "PASS: reverse lookup -x"
	@echo "=== testing allowlist filter ==="
	@./$(BIN) --allowlist "*.openooda.org,openooda.org" openooda.org A | grep -q "openooda.org" && echo "PASS: allowlist pass"
	@echo "=== testing JSON Lines output -j ==="
	@./$(BIN) -j openooda.org A | grep -q '"rcode":"NOERROR"' && echo "PASS: JSON Lines"
	@echo "=== testing MCP initialize ==="
	@printf '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}\n' | ./$(BIN) --mcp | grep -q "protocolVersion" && echo "PASS: MCP initialize"
	@echo "=== testing MCP tools/list ==="
	@printf '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}\n' | ./$(BIN) --mcp | grep -q "dns_resolve" && echo "PASS: MCP tools/list"
	@echo "=== testing MCP tools/call dns_resolve ==="
	@printf '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"dns_resolve","arguments":{"domain":"openooda.org","record_type":"A"}}}\n' | ./$(BIN) --mcp | grep -q "185.199." && echo "PASS: MCP dns_resolve"
	@echo "=== testing MCP tools/call dns_lookup ==="
	@printf '{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"dns_lookup","arguments":{"domain":"openooda.org"}}}\n' | ./$(BIN) --mcp | grep -q "ip" && echo "PASS: MCP dns_lookup"
	@echo "=== testing MCP tools/call dns_reverse ==="
	@printf '{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"dns_reverse","arguments":{"ip":"1.1.1.1"}}}\n' | ./$(BIN) --mcp | grep -q "one.one.one.one" && echo "PASS: MCP dns_reverse"
	@echo "=== testing MCP tools/call dns_doh ==="
	@printf '{"jsonrpc":"2.0","id":6,"method":"tools/call","params":{"name":"dns_doh","arguments":{"domain":"openooda.org","record_type":"A"}}}\n' | ./$(BIN) --mcp | grep -q "DoH" && echo "PASS: MCP dns_doh"
	@echo "=== testing MCP tools/call dns_validate ==="
	@printf '{"jsonrpc":"2.0","id":7,"method":"tools/call","params":{"name":"dns_validate","arguments":{"domain":"tools.openooda.org","allowlist":"*.openooda.org"}}}\n' | ./$(BIN) --mcp | grep -q "allowed" && echo "PASS: MCP dns_validate"
	@echo "=== testing MCP tools/call dns_demo ==="
	@printf '{"jsonrpc":"2.0","id":8,"method":"tools/call","params":{"name":"dns_demo","arguments":{}}}\n' | ./$(BIN) --mcp | grep -q "DNS Resolution Showcase" && echo "PASS: MCP dns_demo"
	@echo "ALL TESTS PASSED"

package-deb: $(BIN)
	@mkdir -p dist/deb-root/DEBIAN dist/deb-root/usr/bin
	@sed "s/^Version:.*/Version: $(VERSION)-1/" packaging/debian/control.binary > dist/deb-root/DEBIAN/control
	@cp $(BIN) dist/deb-root/usr/bin/oodns
	@chmod 0755 dist/deb-root/usr/bin/oodns
	@cp uninstall.sh dist/deb-root/usr/bin/oodns-uninstall
	@chmod 0755 dist/deb-root/usr/bin/oodns-uninstall
	@dpkg-deb --build --root-owner-group dist/deb-root dist/oodns_$(VERSION)-1_amd64.deb
	@rm -rf dist/deb-root
	@echo "built dist/oodns_$(VERSION)-1_amd64.deb"

package-rpm: $(BIN)
	@mkdir -p ~/rpmbuild/SOURCES ~/rpmbuild/SPECS ~/rpmbuild/RPMS
	@cp $(BIN) ~/rpmbuild/SOURCES/oodns-linux-x86_64
	@cp uninstall.sh ~/rpmbuild/SOURCES/uninstall.sh
	@sed "s/^Version:.*/Version: $(VERSION)/" packaging/oodns.spec > ~/rpmbuild/SPECS/oodns.spec
	@rpmbuild -bb ~/rpmbuild/SPECS/oodns.spec
	@cp ~/rpmbuild/RPMS/x86_64/oodns-$(VERSION)*.rpm dist/
	@echo "built dist RPM package"

package-arch: $(BIN)
	@mkdir -p dist/arch-pkg/usr/bin
	@cp $(BIN) dist/arch-pkg/usr/bin/oodns
	@chmod 0755 dist/arch-pkg/usr/bin/oodns
	@cp uninstall.sh dist/arch-pkg/usr/bin/oodns-uninstall
	@chmod 0755 dist/arch-pkg/usr/bin/oodns-uninstall
	@printf "pkgname = oodns\npkgbase = oodns\npkgver = $(VERSION)-1\npkgdesc = Asynchronous DNS resolver supporting DNS-over-HTTPS and capability allowlists in pure openOODA.\nurl = https://github.com/openOODA-tools/oodns\nbuilddate = $$(date +%s)\npackager = openOODA-tools <ops@openooda.org>\nsize = $$(stat -c %s $(BIN))\narch = x86_64\nlicense = Apache-2.0\ndepend = glibc\nprovides = oodns\n" > dist/arch-pkg/.PKGINFO
	@tar --zstd -cf dist/oodns-$(VERSION)-1-x86_64.pkg.tar.zst -C dist/arch-pkg .PKGINFO usr
	@rm -rf dist/arch-pkg
	@bash -n packaging/arch/PKGBUILD
	@cp packaging/arch/PKGBUILD packaging/PKGBUILD
	@echo "built dist/oodns-$(VERSION)-1-x86_64.pkg.tar.zst and validated PKGBUILD"

package: package-deb package-rpm package-arch
	@cd dist && sha256sum oodns* > checksums.txt 2>/dev/null || true
	@echo "built all packages and dist/checksums.txt"

clean:
	@rm -rf dist .ooda-cache
	@echo "cleaned"

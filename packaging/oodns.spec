Name:           oodns
Version:        0.1.0
Release:        1%{?dist}
Summary:        Asynchronous DNS resolver supporting DNS-over-HTTPS and capability allowlists.
License:        ASL 2.0
URL:            https://github.com/openOODA-tools/oodns
Source0:        oodns-linux-x86_64
Source1:        uninstall.sh
BuildArch:      x86_64
Requires:       glibc

%description
oodns is a sovereign, capability-bounded DNS RESOLVER written
in pure openOODA, featuring zero ambient authority, oote color themes,
and an MCP stdio server.

%install
mkdir -p %{buildroot}/usr/bin
install -m 0755 %{SOURCE0} %{buildroot}/usr/bin/oodns
install -m 0755 %{SOURCE1} %{buildroot}/usr/bin/oodns-uninstall

%files
/usr/bin/oodns
/usr/bin/oodns-uninstall

%changelog
* Wed Oct 07 2026 openOODA-tools <ops@openooda.org> - 0.1.0-1
- Initial sovereign blueprint scaffolding

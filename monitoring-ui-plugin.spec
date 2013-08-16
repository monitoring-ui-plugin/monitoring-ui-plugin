Name: monitoring-ui-plugin
Version: 0.1
Release: 1%{?dist}
Summary: Nagios/Icinga Monitoring UI-Plugin for oVirt/RHEV

Group: Applications/System
License: GPLv3+
URL: https://github.com/ovido/monitoring-ui-plugin
Source0: %{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

BuildRequires: perl
BuildRequires: perl-CGI
BuildRequires: perl-Log-Log4perl
BuildRequires: perl-Template-Toolkit
BuildRequires: perl-JSON
BuildRequires: perl-YAML-Syck
BuildRequires: perl-DBI
BuildRequires: perl-DBD-Pg
BuildRequires: perl-JSON-XS

Requires: perl
Requires: perl-CGI
Requires: perl-Log-Log4perl
Requires: perl-Template-Toolkit
Requires: perl-JSON
Requires: perl-YAML-Syck
Requires: perl-DBI
Requires: perl-DBD-Pg
Requires: perl-JSON-XS
Requires: httpd

%define apacheuser apache
%define apachegroup apache

%description
This UI-Plugin for oVirt and RHEV integrates a existing Nagios or Icinga 
monitoring solution into oVirt and RHEV and displays detailed service status
information for data centers, clusters, hosts, storage domains, virtual 
machines and pools including performance graphs.

%prep
%setup -q -n %{name}-%{version}

%build
%configure --prefix=/usr \
           --sbindir=%{_libdir}/%{name} \
           --libdir=%{_libdir}/perl5/vendor_perl \
           --sysconfdir=%{_sysconfdir}/%{name} \
           --datarootdir=%{_datarootdir}/%{name} \
           --with-web-user=%{apacheuser} \
           --with-web-group=%{apachegroup} \
           --with-web-conf=/etc/httpd/conf.d/monitoring-ui.conf \
           --with-plugins-dir=/usr/share/ovirt-engine/ui-plugins

make all


%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT INSTALL_OPTS="" INSTALL_OPTS_WEB=""

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root)
%config(noreplace) %{_sysconfdir}/%{name}/monitoring-ui.yml
%config(noreplace) %attr(-,%{apacheuser},%{apacheuser}) %{_sysconfdir}/%{name}/mappings
%config(noreplace) %{_sysconfdir}/httpd/conf.d/monitoring-ui.conf
%{_libdir}/perl5/vendor_perl
%attr(0755,root,root) %{_libdir}/%{name}/monitoring-ui.cgi
%{_datarootdir}/%{name}
%attr(0755,%{apacheuser},%{apacheuser}) %{_localstatedir}/log/monitoring-ui.log
%{_datarootdir}/ovirt-engine/ui-plugins
%doc AUTHORS ChangeLog COPYING NEWS README sample-config



%changelog
* Sun Aug 18 2013 Rene Koch <r.koch@ovido.at> 0.1-1
- Initial build.

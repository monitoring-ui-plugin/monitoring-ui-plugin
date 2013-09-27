Name: monitoring-ui-plugin
Version: 0.1
Release: 3%{?dist}
Summary: Nagios/Icinga Monitoring UI-Plugin for oVirt/RHEV

Group: Applications/System
License: GPLv3+
URL: https://github.com/monitoring-ui-plugin/development
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
BuildRequires: perl-libwww-perl
BuildRequires: selinux-policy

Requires: perl
Requires: perl-CGI
Requires: perl-FCGI
Requires: perl-Log-Log4perl
Requires: perl-Template-Toolkit
Requires: perl-JSON
Requires: perl-YAML-Syck
Requires: perl-DBI
Requires: perl-DBD-Pg
Requires: perl-DBD-MySQL
Requires: perl-JSON-XS
Requires: perl-libwww-perl
Requires: perl-Time-HiRes
Requires: perl-Crypt-SSLeay
Requires: mod_fcgid
Requires: httpd

Requires(post):   /usr/sbin/semodule, /sbin/restorecon, /sbin/fixfiles
Requires(postun): /usr/sbin/semodule, /sbin/restorecon, /sbin/fixfiles

%define apacheuser apache
%define apachegroup apache
%define sename monitoring-ui

%global selinux_variants mls targeted

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

cd selinux
for selinuxvariant in %{selinux_variants}
do
  make NAME=${selinuxvariant} -f /usr/share/selinux/devel/Makefile
  mv %{sename}.pp %{sename}.pp.${selinuxvariant}
  make NAME=${selinuxvariant} -f /usr/share/selinux/devel/Makefile clean
done
cd -

make all


%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT INSTALL_OPTS="" INSTALL_OPTS_WEB=""

for selinuxvariant in %{selinux_variants}
do
  install -d %{buildroot}%{_datadir}/selinux/${selinuxvariant}
  install -p -m 644 selinux/%{sename}.pp.${selinuxvariant} \
    %{buildroot}%{_datadir}/selinux/${selinuxvariant}/%{sename}.pp
done


%clean
rm -rf $RPM_BUILD_ROOT


%post
for selinuxvariant in %{selinux_variants}
do
  /usr/sbin/semodule -s ${selinuxvariant} -i \
    %{_datadir}/selinux/${selinuxvariant}/%{sename}.pp &> /dev/null || :
done
/sbin/fixfiles -R %{sename} restore || :
/sbin/restorecon -R %{_localstatedir}/cache/%{sename} || :
/usr/sbin/setsebool -P allow_ypbind=on

%postun
if [ $1 -eq 0 ] ; then
  for selinuxvariant in %{selinux_variants}
  do
    /usr/sbin/semodule -s ${selinuxvariant} -r %{sename} &> /dev/null || :
  done
  /sbin/fixfiles -R %{sename} restore || :
  [ -d %{_localstatedir}/cache/%{sename} ]  && \
    /sbin/restorecon -R %{_localstatedir}/cache/%{sename} &> /dev/null || :
fi


%files
%defattr(-,root,root)
%config(noreplace) %{_sysconfdir}/%{name}/monitoring-ui.yml
%config(noreplace) %attr(-,%{apacheuser},%{apacheuser}) %{_sysconfdir}/%{name}/mappings
%config(noreplace) %{_sysconfdir}/httpd/conf.d/monitoring-ui.conf
%{_libdir}/perl5/vendor_perl
%attr(0755,root,root) %{_libdir}/%{name}/monitoring-ui.cgi
%{_datarootdir}/%{name}
%{_datadir}/selinux/*/%{sename}.pp
%attr(0755,%{apacheuser},%{apacheuser}) %{_localstatedir}/log/monitoring-ui.log
%{_datarootdir}/ovirt-engine/ui-plugins
%doc AUTHORS ChangeLog COPYING NEWS README sample-config



%changelog
* Fri Sep 27 2013 Rene Koch <r.koch@ovido.at> 0.1-3
- added SELinux support
- added requirements

* Thu Aug 29 2013 Rene Koch <r.koch@ovido.at> 0.1-2
- added requirement for mod_fcgid and perl-FCGI, perl-DBD-MySQL and perl-Time-HiRes

* Sun Aug 18 2013 Rene Koch <r.koch@ovido.at> 0.1-1
- Initial build.

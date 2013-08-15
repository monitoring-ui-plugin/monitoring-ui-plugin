# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# compiler settings
CGIDIR=@sbindir@
LIBDIR=@libdir@
SYSCONFDIR=@sysconfdir@
INSTALL=@INSTALL@
INSTALL_OPTS=@INSTALL_OPTS@
SCRIPT=monitoring-ui

# compile
all:
	cp $(SCRIPT).cgi.in $(SCRIPT).tmp
	sed -i 's!$lib_path = "../lib";!$lib_path = "$(LIBDIR)";!' $(SCRIPT).tmp
	sed -i 's!$cfg_path = "../etc";!$cfg_path = "$(SYSCONFDIR)";!' $(SCRIPT).tmp
	cp $(SCRIPT).tmp $(SCRIPT).cgi
	rm -f $(SCRIPT).tmp

# install
install:
	for file in *.cgi; do \
	  $(INSTALL) -D -m 755 $(INSTALL_OPTS) $$file $(DESTDIR)$(CGIDIR)/$$file; \
	done

# cleanup
clean:
	rm -f *.cgi

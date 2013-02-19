#!/usr/bin/perl

# This file is part of ovirt-Monitoring UI-Plugin.
#
# ovirt-Monitoring UI-Plugin is free software: you can redistribute it 
# and/or modify it under the terms of the GNU General Public License 
# as published by the Free Software Foundation, either version 3 of the i
# License, or (at your option) any later version.
#
# ovirt-Monitoring UI-Plugin is distributed in the hope that it will be 
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ovirt-Monitoring UI-Plugin.  
# If not, see <http://www.gnu.org/licenses/>.


use strict;
use warnings;
use Template;
use CGI qw(param);
use CGI::Carp qw(fatalsToBrowser);
#use Data::Dumper;

# global variables
my $tt_vars     = "";
my $tt_template = "../src/mon_results_graph.tt";

if (defined param("host")){

print "Content-type: text/html\n\n";

  my $host = param("host");
  my $service = param("service");

}

exit 0;

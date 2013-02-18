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
use JSON::PP;
use Data::Dumper;

# oVirtUI Monitoring Libs
use lib "../lib/";
use oVirtUI::Monitoring::Hosts;

# global variables
my $tt_vars     = "";
my $tt_template = "../src/mon_results_details_tab.tt";

if (defined param("search")){

#print "Content-type: text/html\n\n";

  my $host = param("host");
  my $service = param("service");

  print "Content-type: application/json charset=iso-8859-1\n\n";
  my $json_data = JSON::PP->new->pretty;
  print $json_data->sort_by(sub { $JSON::PP::a cmp $JSON::PP::b })->encode(get_servicedetails($host,$service));

#}else{
#
## show default page
#
## HTML code
#print "Content-type: text/html\n\n";
#
## create new template
#my $template = Template->new({
#    RELATIVE => 1,
#    # where to find template files
#    # TODO: Config file!!!
#    INCLUDE_PATH => ['/data/www/ovirt-monitoring/src'],
#    # pre-process lib/config to define any extra values
#    PRE_PROCESS  => 'config',
#});
#
## display page with template
#$template->process($tt_template, $tt_vars) || die "Template process failed: " . $template->error() . "\n";
#
  }

exit 0;

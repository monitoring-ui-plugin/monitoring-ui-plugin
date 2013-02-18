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

# oVirtUI Monitoring Libs
use lib "../lib/";
use oVirtUI::Monitoring::Hosts;

# HTML code
print "Content-type: text/html\n\n";

# Process URL
if (! defined param){

  print "Parameter needed!";
  exit 1;

}else{

  # global variables
  my $tt_template = undef;
  my $tt_vars     = undef;

  # Search host and service statistics
  if (defined param("subtab")){

    my $subtab = param("subtab");
    my $name = param("name");
    # rename subtab
    chop $subtab;
    $subtab = ucfirst $subtab;

    $tt_vars = {
      'name'  => $name,
      'hosts' => get_results($name)
    };

    my %tt_vars_hash = %{ $tt_vars };

    # Host not found
    if (keys( %{ $tt_vars_hash{'hosts'} } ) == 0){
      $tt_vars = {
        'name' => $name,
        'host' => $subtab
      };
      $tt_template = "../src/mon_results_notfound.tt";
    }else{
      $tt_template = "../src/mon_results_details.tt";
    }

  # Acknowledge service problem
  }elsif (defined param("ack")){

    my $host = param("host");
    my $service = param("service");
    my $user = param("user");

    $tt_vars = {
	'host'    => $host,
	'service' => $service,
	'user'    => $user
    };

    $tt_template = "../src/mon_results_ack.tt";

  # Comment service problem
  }elsif (defined param("comm")){

  }

  # create new template
  my $template = Template->new({
    RELATIVE => 1,
    # where to find template files
    # TODO: Config file!!!
    INCLUDE_PATH => ['/data/www/ovirt-monitoring/src'],
    # pre-process lib/config to define any extra values
    PRE_PROCESS  => 'config',
  });

  # display page with template
  $template->process($tt_template, $tt_vars) || die "Template process failed: " . $template->error() . "\n";

}

exit 0

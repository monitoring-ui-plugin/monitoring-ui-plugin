package oVirtUI::Monitoring::Livestatus;

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
require Exporter;
use Monitoring::Livestatus;

our @ISA	= qw(Exporter);
our @EXPORT	= qw(selectall);
our $VERSION	= 0.01;

# ARG1: Query
sub selectall {
  my $host = $_[0];
  # TODO: use config for port or socket
#  my $ml = Monitoring::Livestatus->new( socket => '/usr/local/icinga/var/rw/live' );
  my $ml = Monitoring::Livestatus->new( server => '127.0.0.1:6557' );
  $ml->errors_are_fatal(0);

#  my @select = $ml->selectall_arrayref("GET services\n
#Columns: display_name state last_check last_state_change plugin_output long_plugin_output perf_data last_notification last_state_change latency next_check notifications_enabled acknowledged comments is_flapping\n
#Filter: host_name =~ $host");
  my @select = $ml->selectall_arrayref("GET services\n
Columns: display_name state plugin_output\n
Filter: host_name =~ $host");

  if($Monitoring::Livestatus::ErrorCode) {
    my $error = "Getting Monitoring checkresults failed: $Monitoring::Livestatus::ErrorMessage";
    die $error;
  }

  return \@select;
}

1;

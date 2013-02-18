package oVirtUI::Monitoring::Hosts;

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
use POSIX qw(strftime);
use oVirtUI::Monitoring::Livestatus;

our @ISA	= qw(Exporter);
our @EXPORT	= qw(get_results get_servicedetails);
our $VERSION	= 0.01;

# ARG1: Hostname
sub get_results{
  my $host = $_[0];
  my @result = GetServices($host,"");
  # construct return hash
  my %rethash;
  for (my $i=0;$i<=$#{$result[0][0]};$i++){
    next unless defined $result[0][0][$i][0];	# skip empty results
    $rethash{$result[0][0][$i][0]}{'service'}	= $result[0][0][$i][0];
    $rethash{$result[0][0][$i][0]}{'status'}	= $result[0][0][$i][1];
    $rethash{$result[0][0][$i][0]}{'output'}	= $result[0][0][$i][2];
    $rethash{$result[0][0][$i][0]}{'hostname'}	= $host;
    $rethash{$result[0][0][$i][0]}{'pnpservice'}	= $result[0][0][$i][0];
    $rethash{$result[0][0][$i][0]}{'pnpservice'}	=~ s/ /_/g;
  }
  return \%rethash;
}

sub get_servicedetails{
  my $host = $_[0];
  my $service = $_[1];
  my @result =  GetServices($host,$service);
  # construct return hash
  my %rethash;
  for (my $i=0;$i<=$#{$result[0][0]};$i++){
    next unless defined $result[0][0][$i][0];       # skip empty results
    $rethash{$result[0][0][$i][0]}{'service'}       = $result[0][0][$i][0];
    $rethash{$result[0][0][$i][0]}{'status'}        = $result[0][0][$i][1];
    $rethash{$result[0][0][$i][0]}{'lastcheck'}    = strftime ("%Y-%m-%d %H:%M:%S", localtime( $result[0][0][$i][2] ));
    $rethash{$result[0][0][$i][0]}{'duration'}     = strftime ("%Y-%m-%d %H:%M:%S", localtime( $result[0][0][$i][3] ));
    $rethash{$result[0][0][$i][0]}{'output'}       = $result[0][0][$i][4];
    $rethash{$result[0][0][$i][0]}{'hostname'}      = $host;
    $rethash{$result[0][0][$i][0]}{'long_plugin_output'} = $result[0][0][$i][5];
    $rethash{$result[0][0][$i][0]}{'perf_data'}    = $result[0][0][$i][6];
    $rethash{$result[0][0][$i][0]}{'last_notification'}    = $result[0][0][$i][7];
    $rethash{$result[0][0][$i][0]}{'last_state_change'}    = strftime ("%Y-%m-%d %H:%M:%S", localtime( $result[0][0][$i][8] ));
    $rethash{$result[0][0][$i][0]}{'latency'}      = $result[0][0][$i][9];
    $rethash{$result[0][0][$i][0]}{'next_check'}   = strftime ("%Y-%m-%d %H:%M:%S", localtime( $result[0][0][$i][10] ));
    $rethash{$result[0][0][$i][0]}{'notifications_enabled'}        = $result[0][0][$i][11];
    $rethash{$result[0][0][$i][0]}{'acknowledged'} = $result[0][0][$i][12];
    $rethash{$result[0][0][$i][0]}{'comments'}     = $result[0][0][$i][13];
    $rethash{$result[0][0][$i][0]}{'is_flapping'}  = $result[0][0][$i][14];
  }
  return \%rethash;
}

1;

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
our @EXPORT	= qw(get_hostresults);
our $VERSION	= 0.01;

# ARG1: Hostname
sub get_hostresults{
  my $host = $_[0];
  my @hostresult = selectall($host);
  # construct return hash
  my %rethash;
  for (my $i=0;$i<=$#{$hostresult[0][0]};$i++){
    next unless defined $hostresult[0][0][$i][0];	# skip empty results
    $rethash{$hostresult[0][0][$i][0]}{'service'}	= $hostresult[0][0][$i][0];
    $rethash{$hostresult[0][0][$i][0]}{'status'}	= $hostresult[0][0][$i][1];
    $rethash{$hostresult[0][0][$i][0]}{'lastcheck'}	= strftime ("%Y-%m-%d %H:%M:%S", localtime( $hostresult[0][0][$i][2] ) );
    $rethash{$hostresult[0][0][$i][0]}{'duration'}	= strftime ("%Y-%m-%d %H:%M:%S", localtime( $hostresult[0][0][$i][3] ) );
    $rethash{$hostresult[0][0][$i][0]}{'output'}	= $hostresult[0][0][$i][4];
    $rethash{$hostresult[0][0][$i][0]}{'hostname'}	= $host;
    $rethash{$hostresult[0][0][$i][0]}{'pnpservice'}	= $hostresult[0][0][$i][0];
    $rethash{$hostresult[0][0][$i][0]}{'pnpservice'}	=~ s/ /_/g;
  }
  return \%rethash;
}

1;

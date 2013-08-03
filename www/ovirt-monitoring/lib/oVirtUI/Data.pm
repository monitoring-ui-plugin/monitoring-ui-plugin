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

package oVirtUI::Data;

BEGIN {
    $VERSION = '0.301'; # Don't forget to set version and release
}  						# date in POD below!

use strict;
use warnings;
use YAML::Syck;
use CGI::Carp qw(fatalsToBrowser);
use File::Spec;
use JSON::PP;

# for debugging only
use Data::Dumper;


=head1 NAME

  oVirtUI::Data - Connect to data backend

=head1 SYNOPSIS

  use oVirtUI::Data;
  my $details = oVirtUI::Data->new(
  		provider	=> 'ido',
  		provdata	=> $provdata,
  		host		=> $host,
  	 );
  $json = $details->get_services();

=head1 DESCRIPTION

This module fetches service details for given hosts from various backends like
IDOutils and mk-livestatus.

=head1 CONSTRUCTOR

=head2 new ( [ARGS] )

Creates an oVirtUI::Data object. <new> takes at least the provider and provdata.
Arguments are in key-value pairs.
See L<EXAMPLES> for more complex variants.

=over 4

=item provider

name of datasource provider (supported: ido|mk-livestatus)

=item provdata

provider specific connection data

IDO:
  host: hostname (e.g. localhost)
  port: port (e.g. 3306)
  type: mysql|pgsql
  database: database name (e.g. icinga)
  username: database user (e.g. icinga)
  password: database password (e.g. icinga)
  prefix: database prefix (e.g. icinga_)
  
mk-livestatus:
  socket: socket of mk-livestatus
  server: ip/hostname of mk-livestatus
  port: port of mk-livestatus

=item host

name of Icinga host object to query service details from
required for oVirtUI::Data->get_services()

=cut


sub new {
  my $invocant	= shift;
  my $class 	= ref($invocant) || $invocant;
  my %options	= @_;
    
  my $self 		= {
  	"host"		=> undef,	# name of host to query data for
  	"service"	=> undef,	# name of service to query data for
  	"provider"	=> "ido",	# provider (ido | mk-livestatus)
  	"provdata"	=> undef,	# provider details like hostname, username,... 
  };
  
  for my $key (keys %options){
  	if (exists $self->{ $key }){
  	  $self->{ $key } = $options{ $key };
  	}else{
  	  croak "Unknown option: $key";
  	}
  }
  
  # parameter validation
  # TODO!
  
  bless $self, $class;
  return $self;
}


#----------------------------------------------------------------

=head1 METHODS	

=head2 get_services

 get_status ( 'host' => $host )

Connects to backend and queries details of given host.
Returns JSON data.

  my $json = $get_services( 'host' => $host );
  
$VAR1 = {
   "Current Load" : {
      "output" : "OK - load average: 0.00, 0.00, 0.00",
      "service" : "Current Load",
      "state" : 0
   },
 }                               	

=cut

sub get_services {
	
  my $self		= shift;
  my %options 	= @_;
  
  for my $key (keys %options){
  	if (exists $self->{ $key }){
  	  $self->{ $key } = $options{ $key };
  	}else{
  	  croak "Unknown option: $key";
  	}
  }
  
  my $result = undef;
  # fetch data from Icinga/Nagios
  if ($self->{'provider'} eq "ido"){
  	
  	# construct SQL query
  	my $sql = $self->_query_ido( $self->{ 'host' } );
  	# get results
  	$result = $self->_get_ido( $sql );
  	
    if ($self->{'errors'}){
      # TODO!!!
      return 1;
    }
    
  }elsif ($self->{'provider'} eq "mk-livestatus"){
  	
  	# construct query
  	my $query = $self->_query_livestatus( $self->{ 'host' } );
  	# get results
  	$result = $self->_get_livestatus( $query );
  	
  }else{
  	carp ("Unsupported provider: $self->{'provider'}!");
  }
  
  # change hash into array of hashes for JS template processing
  my $tmp;
  foreach my $key (keys %{ $result }){
  	
  	$result->{ $key }{ 'state' } = "../share/images/icons/arrow-" . $result->{ $key }{ 'state' } . ".png";
  	push @{ $tmp }, $result->{ $key };
  	
  }
  
  # produce json output
  my $json = JSON::PP->new->pretty;
  $json = $json->sort_by(sub { $JSON::PP::a cmp $JSON::PP::b })->encode( $tmp );
  
  return $json;
  
}


#----------------------------------------------------------------

=head1 METHODS	

=head2 get_details

 get_details ( 'host' => $host, service => $service )

Connects to backend and queries details of given host and service.
Returns JSON data.

  my $json = $get_details ( 'host' => $host, service => $service );
  
=cut

sub get_details {
	
  my $self		= shift;
  my %options 	= @_;
  
  for my $key (keys %options){
  	if (exists $self->{ $key }){
  	  $self->{ $key } = $options{ $key };
  	}else{
  	  croak "Unknown option: $key";
  	}
  }
  
  my $result = undef;
  # fetch data from Icinga/Nagios
  if ($self->{'provider'} eq "ido"){
  	
  	# construct SQL query
  	my $sql = $self->_query_ido( $self->{ 'host' }, $self->{ 'service' } );
  	# get results
  	$result = $self->_get_ido( $sql );
  	
    if ($self->{'errors'}){
      # TODO!!!
      return 1;
    }
    
  }elsif ($self->{'provider'} eq "mk-livestatus"){
  	
  	# construct query
  	my $query = $self->_query_livestatus( $self->{ 'host' }, $self->{ 'service' } );
  	# get results
  	$result = $self->_get_livestatus( $query );
  	
  }else{
  	carp ("Unsupported provider: $self->{'provider'}!");
  }
  
  # change hash into array of hashes for JS template processing
  # bring in format:
  # [
  #    { name: key,
  #      value: key
  #    },
  #    { ... }
  # ]
  my $tmp;
  foreach my $key (keys %{ $result->{ $self->{ 'service' } } }){
  	
  	my $x;
  	$x->{ 'name' } = $key;
  	$x->{ 'value' } = $result->{ $self->{ 'service' } }{ $key };
  	push @{ $tmp }, $x;
  	
  }
  
  # produce json output
  my $json = JSON::PP->new->pretty;
  $json = $json->sort_by(sub { $JSON::PP::a cmp $JSON::PP::b })->encode( $tmp );
  
  return $json;
  
}


#----------------------------------------------------------------

# internal methods
##################

# construct SQL query for IDOutils
sub _query_ido {
	
  my $self		= shift;
  my $hostname	= shift or croak ("Missing hostname!");
  my $service	= shift;
  
  chomp $hostname;
  my $sql = undef;
  
  # if service is given get service details otherwise get services
  if ($service){
  	
  	# construct SQL query
  	$sql  = "SELECT name2 AS service, current_state, last_check, last_state_change, output, long_output, perfdata, last_notification, last_state_change, ";
  	$sql .= "latency, next_check, notifications_enabled, problem_has_been_acknowledged, comment_data, is_flapping ";
  	$sql .= "FROM " . $self->{'provdata'}{'prefix'} . "objects INNER JOIN " . $self->{'provdata'}{'prefix'} . "servicestatus ";
  	$sql .= "ON " . $self->{'provdata'}{'prefix'} . "objects.object_id = service_object_id LEFT OUTER JOIN " . $self->{'provdata'}{'prefix'} . "comments ";
  	$sql .= "ON " . $self->{'provdata'}{'prefix'} . "objects.object_id = " . $self->{'provdata'}{'prefix'} . "comments.object_id ";
  	$sql .= "WHERE is_active = 1 AND name1 = '$hostname' AND name2 = '$service'";
  	
  }else{
  
    # construct SQL query
    $sql  = "SELECT name2 AS service, current_state AS state, output FROM " . $self->{'provdata'}{'prefix'} . "objects, " . $self->{'provdata'}{'prefix'} . "servicestatus ";
    $sql .= "WHERE object_id = service_object_id AND is_active = 1 AND name1 = '$hostname';";
    
  }
  
  return $sql;
  
}


#----------------------------------------------------------------

# construct livetstatus query
sub _query_livestatus {
	
  my $self		= shift;
  my $hostname	= shift or croak ("Missing hostname!");
  my $service   = shift;
  
  chomp $hostname;
  my $query = undef;
  
  # if service is given get service details otherwise get services
  if ($service){
  	
  	# construct livestatus query
  	$query = "GET services\n
Columns: display_name state last_check last_state_change plugin_output long_plugin_output perf_data last_notification last_state_change latency next_check notifications_enabled acknowledged comments is_flapping\n
Filter: host_name =~ $hostname\n
Filter: display_name =~ $service\n";
  	
  }else{
  
    # construct livestatus query
    $query = "GET services\n
Columns: display_name state plugin_output\n
Filter: host_name =~ $hostname";

  }
  
  return $query;
  
}


#----------------------------------------------------------------

# get service status from IDOutils
sub _get_ido {
	
  my $self	= shift;
  my $sql	= shift or croak ("Missing SQL query!");
  
  my $result;
  
  my $dsn = undef;
  # database driver
  if ($self->{'provdata'}{'type'} eq "mysql"){
    use DBI;	  # MySQL
  	$dsn = "DBI:mysql:database=$self->{'provdata'}{'database'};host=$self->{'provdata'}{'host'};port=$self->{'provdata'}{'port'}";
  }elsif ($self->{'provdata'}{'type'} eq "pgsql"){
	use DBD::Pg;  # PostgreSQL
  	$dsn = "DBI:Pg:dbname=$self->{'provdata'}{'database'};host=$self->{'provdata'}{'host'};port=$self->{'provdata'}{'port'}";
  }else{
  	croak "Unsupported database type: $self->{'provdata'}{'type'}";
  }
  
  # connect to database
  my $dbh   = DBI->connect($dsn, $self->{'provdata'}{'username'}, $self->{'provdata'}{'password'});
  if ($DBI::errstr){
  	push @{ $self->{'errors'} }, "Can't connect to database: $DBI::errstr";
  	return 1;
  }
  my $query = $dbh->prepare( $sql );
  $query->execute;
  if ($DBI::errstr){
  	push @{ $self->{'errors'} }, "Can't execute query: $DBI::errstr";
    $dbh->disconnect;
  	return 1;
  }
  
  # prepare return
  $result = $query->fetchall_hashref('service');
  
  # disconnect from database
  $dbh->disconnect;
  
  return $result;
  
}


#----------------------------------------------------------------

# get service status from mk-livestatus
sub _get_livestatus {
	
  my $self	= shift;
  my $query	= shift or croak ("Missing livestatus query!");
  
  my $result;
  my $ml;
  
  use Monitoring::Livestatus;
  
  # use socket or hostname:port?
  if ($self->{'provdata'}{'socket'}){
    $ml = Monitoring::Livestatus->new( 'socket' => $self->{'provdata'}{'socket'} );
  }else{
    $ml = Monitoring::Livestatus->new( 'server' => $self->{'provdata'}{'server'} . ':' . $self->{'provdata'}{'port'} );
  }
  
  $ml->errors_are_fatal(0);
  $result = $ml->selectall_hashref($query, "display_name");
  
  if($Monitoring::Livestatus::ErrorCode) {
    croak "Getting Monitoring checkresults failed: $Monitoring::Livestatus::ErrorMessage";
  }
  
  foreach my $key (keys %{ $result }){
  	
    # rename columns
    $result->{ $key }{ 'service' } = delete $result->{ $key }{ 'display_name' };
    $result->{ $key }{ 'output' } = delete $result->{ $key }{ 'plugin_output' };
    
  }
  
  return $result;
  
}


1;


=head1 EXAMPLES

Get service details from IDOutils for host named 'localhost'

  use oVirtUI::Data;
  my $details = oVirtUI::Data->new(
  	provider	=> 'ido',
  	provdata	=> $provdata,
  	host		=> "localhost",
  );
  $json = $details->get_services();


=head1 SEE ALSO

See oVirtUI::Config for reading and parsing config files.

=head1 AUTHOR

Rene Koch, E<lt>r.koch@ovido.atE<gt>

=head1 VERSION

Version 0.301  (Aug 03 2013))

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Rene Koch <r.koch@ovido.at>

This library is free software; you can redistribute it and/or modify
it under the same terms as oVirtUI itself.

=cut



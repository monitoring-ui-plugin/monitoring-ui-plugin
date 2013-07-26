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
    $VERSION = '0.100'; # Don't forget to set version and release
}  						# date in POD below!

use strict;
use warnings;
use YAML::Syck;
use CGI::Carp qw(fatalsToBrowser);
use File::Spec;
use JSON::PP;

# for debugging only
#use Data::Dumper;


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
  
  chomp $self->{ 'bp' } if defined $self->{ 'bp' };
  
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
  	# TODO: later!
  	
  }else{
  	carp ("Unsupported provider: $self->{'provider'}!");
  }
  
  
  # produce json output
  my $json = JSON::PP->new->pretty;
  $json = $json->sort_by(sub { $JSON::PP::a cmp $JSON::PP::b })->encode($result);
  
  return $json;
  
}


#----------------------------------------------------------------

# internal methods
##################

# construct SQL query for IDOutils
sub _query_ido {
	
  my $self		= shift;
  my $hostname	= shift or croak ("Missing hostname!");
  chomp $hostname;
  
  # construct SQL query
  my $sql = "SELECT name2 AS service, current_state AS state, output FROM " . $self->{'provdata'}{'prefix'} . "objects, " . $self->{'provdata'}{'prefix'} . "servicestatus ";
    $sql .= "WHERE object_id = service_object_id AND is_active = 1 AND name1 = '$hostname';";
  
  return $sql;
  
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

Version 0.100  (July 26 2013))

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Rene Koch <r.koch@ovido.at>

This library is free software; you can redistribute it and/or modify
it under the same terms as oVirtUI itself.

=cut



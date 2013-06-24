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

package oVirtUI::Config;

use strict;
use warnings;
use CGI::Carp qw(fatalsToBrowser);
use YAML::Syck;
use File::Spec;
use Data::Dumper;


# create an empty oVirtUI::Config object
sub new {
  my $invocant	= shift;
  my $class 	= ref($invocant) || $invocant;
  my $self 		= {
  		"verbose"			=> 0,	# enable verbose output
  };
  
  bless $self, $class;
  return $self;
}


sub read_config {
  my $self	= shift;
  my $file	= shift or croak ("Missing file to read!");
  my %return;
  
  # read and parse YAML config file
  chomp $file;
  $YAML::Syck::ImplicitTyping = 1;
  my $yaml = LoadFile($file);
  
  my @tmp = split /\//, $file;
  $tmp[-1] =~ s/\.yml$//;
  # push into hash with first element name = config file name (without file ending)
  # e.g. monitoring-ui.yml => $conf{'monitoring-ui'}
  $return{ $tmp[-1] } = $yaml;
  
  return \%return;
}


sub read_dir {
  my $self	= shift;
  my $dir	= shift or croak ("Missing directory to read!");
  
  croak ("Read Config: Input parameter $dir isn't a directory!") if ! -d $dir;
  
  my %conf;
  
  # get list of config files
  opendir (CONFDIR, $dir) or croak ("Read Config: Can't open directory $dir: $!");
  
  while (my $file = readdir (CONFDIR)){
   # use absolute path instead of relative
   next if $file =~ /\.\./;
   $file = File::Spec->rel2abs($dir . "/" . $file);
   # skip directories
   next if -d $file;
   chomp $file;
    my @tmp = split /\//, $file;
    $tmp[-1] =~ s/\.yml$//;
    # get content of files
    my %ret = %{ oVirtUI::Config->read_config( $file ) };
    # push into hash with first element name = config file name (without file ending)
    # e.g. monitoring-ui.yml => $conf{'monitoring-ui'}
    $conf{ $tmp[-1] } = $ret{ $tmp[-1] };
  }
  
  closedir (CONFDIR);
  
  return \%conf;
  
}


sub validate {
  my $self		= shift;
  my $config	= shift or croak ("Missing config!");
  
  # go through config values
  # config file name hardcoded to monitoring-ui - change maybe
  # parameters given?
  push @{ $self->{'errors'} }, "src_dir missing!" unless $config->{'monitoring-ui'}{'ui-plugin'}{'src_dir'};
  push @{ $self->{'errors'} }, "data_dir missing!" unless $config->{'monitoring-ui'}{'ui-plugin'}{'data_dir'};
  push @{ $self->{'errors'} }, "site_url missing!" unless $config->{'monitoring-ui'}{'ui-plugin'}{'site_url'};
  push @{ $self->{'errors'} }, "provider missing!" unless $config->{'monitoring-ui'}{'provider'}{'source'};
  $self->_check_dir( "src_dir", $config->{'monitoring-ui'}{'ui-plugin'}{'src_dir'} );
  $self->_check_dir( "data_dir", $config->{'monitoring-ui'}{'ui-plugin'}{'data_dir'} );
  $self->_check_dir( "template", "$config->{'monitoring-ui'}{'ui-plugin'}{'src_dir'}/$config->{'monitoring-ui'}{'ui-plugin'}{'template'}" );
  $self->_check_provider( "provider", $config->{'monitoring-ui'}{'provider'}{'source'}, $config->{'monitoring-ui'} );
  
  if ($self->{'errors'}){
  	print "<p>";
  	print "Configuration validation failed: <br />";
  	for (my $x=0;$x< scalar @{ $self->{'errors'} };$x++){
  	  print $self->{'errors'}->[$x] . "<br />";
  	}
  	print "</p>";
  	return 1;
  }
  
  return 0;
}


# internal methods
sub _check_dir {
  my $self	= shift;
  my $conf	= shift;
  my $dir	= shift or croak ("Missing directory!");
  
  if (! -d $dir){
  	push @{ $self->{'errors'} }, "$conf: $dir - No such directory!";
  }
}


sub _check_provider {
  my $self		= shift;
  my $conf		= shift;
  my $provider	= shift or croak ("Missing provider!");
  my $config	= shift or croak ("Missing config!");
  
  if ($provider ne "ido" && $provider ne "mk-livestatus"){
  	push @{ $self->{'errors'} }, "$conf: $provider not supported!";
  }else{
  	# check provider
  	if ($provider eq "ido"){
  	  push @{ $self->{'errors'} }, "ido: Missing host!" unless $config->{ $provider }{'host'};
  	  push @{ $self->{'errors'} }, "ido: Missing database!" unless $config->{ $provider }{'database'};
  	  push @{ $self->{'errors'} }, "ido: Missing username!" unless $config->{ $provider }{'username'};
  	  push @{ $self->{'errors'} }, "ido: Missing password!" unless $config->{ $provider }{'password'};
  	  push @{ $self->{'errors'} }, "ido: Missing prefix!" unless $config->{ $provider }{'prefix'};
  	  push @{ $self->{'errors'} }, "ido: Unsupported database type: $config->{ $provider }{'type'}!" unless $config->{ $provider }{'type'} eq "mysql";
  	}elsif ($provider eq "mk-livestatus"){
  	  # mk-livestatus requires socket or server
  	  if (! $config->{ $provider }{'socket'} && ! $config->{ $provider }{'server'}){
  	  	push @{ $self->{'errors'} }, "mk-livestatus: Missing server or socket!";
  	  }else{
  	  	if ($config->{ $provider }{'server'}){
  	  	  push @{ $self->{'errors'} }, "mk-livestatus: Missing port!" unless $config->{ $provider }{'port'};
  	  	}
  	  }
  	}
  }
}


return 1;

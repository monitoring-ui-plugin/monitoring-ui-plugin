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
use CGI::Session;
use CGI::Carp qw(fatalsToBrowser);

# for debugging only
use Data::Dumper;

# define default paths required to read config files
my ($lib_path, $cfg_path);
BEGIN {
  $lib_path = "../lib";		# path to BPView lib directory
  $cfg_path = "../etc";		# path to BPView etc directory
}


# load custom Perl modules
use lib "$lib_path";
use oVirtUI::Config;
use oVirtUI::Web;
use oVirtUI::Data;
#use oVirtUI::Monitoring::Hosts;


# global variables
my $session_cache	= 3600;	# 1 hour
my $config;


### The main script starts here


# HTML code
print "Content-type: text/html\n\n" unless defined param;

# CGI sessions
my $post	= CGI->new;
my $sid		= $post->cookie("CGISESSID") || undef;
my $session	= new CGI::Session(undef, $sid, {Directory=>File::Spec->tmpdir});
   $session->expire('config', $session_cache);
my $cookie	= $post->cookie(CGISESSID => $session->id);
# for debugging only
#print $post->header( -cookie=>$cookie );

# open config files if not cached
my $conf	= oVirtUI::Config->new();

if (! $session->param('config')){

  # open config file directory and push configs into hash
  $config	= $conf->read_dir( 'dir' => $cfg_path );
  # validate config
  exit 1 unless ( $conf->validate( 'config' => $config ) == 0);
  # cache config
  $session->param('config', $config);
  
}else{
	
  $config	= $session->param('config');
  
}


# process URL
if (defined param){

  if (defined param("results")){	
  	
    print "Content-type: text/html\n\n";

    # display web page
    my $page = oVirtUI::Web->new(
 		data_dir	=> $config->{ 'ui-plugin' }{ 'data_dir' },
 		site_url	=> $config->{ 'ui-plugin' }{ 'site_url' },
 		template	=> $config->{ 'ui-plugin' }{ 'template' },
	);
   $page->display_page(
    	page	=> "results",
    	content	=> param("host"),		# get name of vm/host
    	refresh	=> $config->{ 'refresh' }{ 'interval' },
	);

  }elsif (defined param("host")){
  	
  	# JSON Header
    print "Content-type: application/json charset=iso-8859-1\n\n";
    my $json = undef;
  	
  	# get services for specified host
    my $services = oVirtUI::Data->new(
    	 provider	=> $config->{ 'provider' }{ 'source' },
    	 provdata	=> $config->{ $config->{ 'provider' }{ 'source' } },
       );	
    
    # is service given, too then get details for service
    # else get all services for this host
    if (defined param("service")){
    	
      $json = $services->get_details( 	'host'		=> param("host"),
      									'service'	=> param("service")
      								);
    	
    }else{
    	
      $json = $services->get_services( 'host'	=> param("host") );
    
    }
    
    print $json;
    exit 0;
  	

  }else{
  	
  	die "Unknown parameter: " . param;
  	
  }
	
  
}else{
	
  die "Parameter needed!";
	
}




exit 0;


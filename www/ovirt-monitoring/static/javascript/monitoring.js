// This file is part of ovirt-Monitoring UI-Plugin.
//
// ovirt-Monitoring UI-Plugin is free software: you can redistribute it 
// and/or modify it under the terms of the GNU General Public License 
// as published by the Free Software Foundation, either version 3 of the i
// License, or (at your option) any later version.
//
// ovirt-Monitoring UI-Plugin is distributed in the hope that it will be 
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with ovirt-Monitoring UI-Plugin.  
// If not, see <http://www.gnu.org/licenses/>.


// clickable table rows in monitoring results
$(document).ready(function() {

    $('#mon-res-tbl tr').hover(
      function() {
	if(! $(this).hasClass("mon-res-body-tr-selected") ){
	  // change css only if table row is not selected
	  $(this).toggleClass("mon-res-body-tr-hover");
	}
    },
      function() {
        if(! $(this).hasClass("mon-res-body-tr-selected") ){
          // change css only if table row is not selected
          $(this).removeClass("mon-res-body-tr-hover");
        }
    });

    $('#mon-res-tbl tr').click(
      function() {
	// reset all table rows first
	$('#mon-res-tbl tr').removeClass("mon-res-body-tr-selected");
	// mark active table row as selected
	$(this).toggleClass("mon-res-body-tr-selected");

	// get status and service name
	var status = $(this).find("div").attr("status");
	var service = $(this).find("div").attr("service");
        var host = $(this).find("div").attr("host");

	// reset all divs first
	$('#mon-res-action-tbl-ack').removeClass("mon-res-action-tbl-selected");
	$('#mon-res-action-tbl-com').removeClass("mon-res-action-tbl-selected");
	$('#mon-res-action-tbl-down').removeClass("mon-res-action-tbl-selected");
	$('#mon-res-action-tbl-not').removeClass("mon-res-action-tbl-selected");
	$('#mon-res-action-tbl-sched').removeClass("mon-res-action-tbl-selected");

	// these buttons should always be clickable
	$('#mon-res-action-tbl-com').toggleClass("mon-res-action-tbl-selected");
	$('#mon-res-action-tbl-down').toggleClass("mon-res-action-tbl-selected");
	$('#mon-res-action-tbl-not').toggleClass("mon-res-action-tbl-selected");
	$('#mon-res-action-tbl-sched').toggleClass("mon-res-action-tbl-selected");

        if(status != 0) {
	  // special buttons only if status is not OK
	  $('#mon-res-action-tbl-ack').toggleClass("mon-res-action-tbl-selected");
	}

	// update details and graphs subtab
	// Get JSON data
	$.getJSON("/ovirt-monitoring/cgi/json.cgi?search=details&host=" + host + "&service=" + service, function(json){
	  $('#mon-res-details-sub-tbody').empty();
	  $.each(json, function(service, serviceval) {
	   var tdClass = 'class="mon-res-body-td mon-res-subtab-td"';
	   var i=0;
	    $.each(serviceval, function(name, value){
	      if (i%2!=0){
		var trClass = 'class="mon-res-body-tr"';
	      }else{
		var trClass = 'class="mon-res-body-tr2"';
	      }
	      $('#mon-res-details-sub-tbody').append('<tr ' + trClass + ' onclick=""><td ' + tdClass + ' width="150">' + name + '</td><td ' + tdClass + ' width="460"><div style="width: 460px;">' + value + '</div></td></tr>');
	      // check if perfdata are available for this service
	      if (name == "perf_data"){
	        if (value){
		  // include performance data
		  $('#mon-res-details-sub-graph').empty();
		  $('#mon-res-details-sub-graph').append(
'			<tr class="mon-res-body-tr"><td class="mon-res-graph"><div style="outline:none;" class="mon-res-graph"><br />4 Hours</div>' +
'			<img src="/pnp4nagios/image?host=' + host + '&srv=' + service + '&view=0"></td></tr>' +
'			<tr class="mon-res-body-tr"><td class="mon-res-graph"><div style="outline:none;" class="mon-res-graph"><br />25 Hours</div>' +
'			<img src="/pnp4nagios/image?host=' + host + '&srv=' + service + '&view=1"></td></tr>' +
'			<tr class="mon-res-body-tr"><td class="mon-res-graph"><div style="outline:none;" class="mon-res-graph"><br />1 Week</div>' +
'			<img src="/pnp4nagios/image?host=' + host + '&srv=' + service + '&view=2"></td></tr>' +
'			<tr class="mon-res-body-tr"><td class="mon-res-graph"><div style="outline:none;" class="mon-res-graph"><br />1 Month</div>' +
'			<img src="/pnp4nagios/image?host=' + host + '&srv=' + service + '&view=3"></td></tr>' +
'			<tr class="mon-res-body-tr"><td class="mon-res-graph"><div style="outline:none;" class="mon-res-graph"><br />1 Year</div>' +
'			<img src="/pnp4nagios/image?host=' + host + '&srv=' + service + '&view=4"><br /></td></tr>'
		  );
		}else{
		  $('#mon-res-graph').empty();
		  $('#mon-res-graph').append('<p>No graphs available for service' + service + '!</p>');
		}
	      }
	      i++;
	    });
	  });
	});
      }
    );

    // Show acknowledge service check dialog
    $('#mon-res-action-tbl-ack').click(
      function() {
	// TODO: don't open dialog if not css class mon-res-action-tbl-selected

	// Open Dialog using Plugin UI API
	var api = parent.pluginApi('monitoring');
	var conf = api.configObject();

        // get status and service name
        var service = $('#mon-res-action-srv').attr("service");
        var host = $('#mon-res-action-srv').attr("host");
	var user = api.loginUserName();

	// Change hard-coded URL to config
	api.showDialog("Acknowledge Service Problem", "/ovirt-monitoring/cgi/index.cgi?host=" + host + "&service=" + service + "&ack=1&user=" + user, 450, 500);
	api.ready();
      }
    );

    $(function() {
	$( "#tabs" ).tabs({
	  beforeLoad: function( event, ui ) {
	    ui.jqXHR.error(function() {
	      ui.panel.html(
		"Couldn't load this tab. We'll try to fix this as soon as possible. " +
		"If this wouldn't be a demo." );
	    });
	  }
	});
    });

});


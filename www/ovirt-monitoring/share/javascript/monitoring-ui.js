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

  // get JSON data
  getResults();
  setInterval("getResults()", refreshInterval);
  
  
  // show tabs
  $(function() {
	$( "#tabs" ).tabs({
	  beforeLoad: function( event, ui ) {
		ui.jqXHR.error(function() {
		  ui.panel.html(
		    "Couldn't load tabs. " );
		});
	  }
	});
  });
  
});



// clickable rows
$(document).on('click', 'tr#mon-res-body-tr', function(){

  var serviceName = $(this).find('#mon-res-body-service').text();
  var hostName = $("div[id='service-details']").attr("host");
  
});



// get service stati for selected host/vm
function getResults(){
	
  // get hostname
  var hostName = $("div[id='service-details']").attr("host");
  $.getJSON( "?host=" + hostName, function(data){
	  
    jsonData = data;
    // TODO: remove overwriteCache in production!!!
	$('#mon-res-tbl-services tbody').loadTemplate("../share/js-templates/service_details.html", jsonData, overwriteCache=true);
	  
  })
  
}



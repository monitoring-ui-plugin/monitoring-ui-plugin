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
  //setInterval("getResults()", refreshInterval);
  setInterval("getResults()", 30000);
	
});


// get service stati for selected host/vm
function getResults(){
	
  // get hostname
  var hostName = $("div[id='service-details']").attr("host");
  $.getJSON( "?host=" + hostName, function(data){
	  
	var jsonData = '<table width="100%" class="mon-res-head-tbl" id="mon-res-tbl" cellspacing="0">';
        jsonData += '<tbody style="">';
	$.each(data, function(service, serviceVal){
		
//	  if (index % 2){
		jsonData += '<tr class="mon-res-body-tr2" onClick="">';
//	  }else{
//		jsonData += '<tr class="mon-res-body-tr" onClick="">';
//	  }
	  
	  jsonData += ' <td class="mon-res-body-td" colspan="1" width="25">';
	  jsonData += '   <div style="outline:none;" id="mon-res-action-srv">';
      jsonData += '      <div>';
	  
      if (serviceVal.state == 0){
    	jsonData += '<img src="../share/images/icons/arrow-ok.png" />';
      }
		
      jsonData += '</div>';
      jsonData += '</div>';
      jsonData += '</td>';
      jsonData += '<td class="mon-res-body-td" width="170">';
      jsonData += '<div style="outline:none;">';
      jsonData += '<div id="mon-res-body-trim" style="overflow:hidden;">' + serviceVal.service + '</div>';
      jsonData += '</div>';
      jsonData += '</td>';
      jsonData += '<td class="mon-res-body-td">';
      jsonData += '<div style="outline:none;">';
      jsonData += '<div id="mon-res-body-trim" style="overflow:hidden;">' + serviceVal.output + '</div>';
      jsonData += '</div>';
      jsonData += '</td>';
      jsonData += '</tr>';
  	    
	// display error message on empty returns
//	if (jsonData == ""){
		// do something!
//	}
      
	})
  	  
  	jsonData += '    </tbody>';
    jsonData += '</table>';
	  
    // update details
	$('#service-details').empty();
	$('#service-details').append(jsonData);
	  
	//})
	  
  })
  
}



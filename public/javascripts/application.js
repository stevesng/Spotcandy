// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function() {
  $('a.nolink').live('click', function(e){e.preventDefault();});
  
  $( "#confirm" ).dialog({ 
                         autoOpen: false,
                         modal: true,
                         draggable: false,
                         resizable: false,
                         dialogClass: 'alert'
                         });
  
  $( "#photo_popup" ).dialog({ 
                         autoOpen: false,
                         modal: true,
                         position:'top',
                         draggable: false,
                         resizable: false });
  
  $( "#candy_added" ).dialog({ 
                         dialogClass: 'candy_added',
                         autoOpen: false,
                         modal: true,
                         draggable: false,
                         resizable: false ,
                         buttons: [{
                                   text: "Close",
                                   click: function() { 
                                   $(this).dialog("close");
                                   }
                                   }]});
  
});
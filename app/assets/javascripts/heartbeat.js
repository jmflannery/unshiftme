////////////////////////////////////////
// heartbeat
////////////////////////////////////////

$(function() {
  if ($('#content').length > 0) {
    setTimeout(heartbeat, 10000);
  }
});

var heartbeat = function() {
  // store the current user's name
  user_name = $("#main_menu").attr("class");
  
  $.ajax( {
    type: "PUT",
    url: "/users/" + user_name + "/heartbeat.js",
    success: function(response) {
      response;
    }
  });
  
  setTimeout(heartbeat, 10000);
};


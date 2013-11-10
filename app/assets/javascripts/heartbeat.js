////////////////////////////////////////
// heartbeat
////////////////////////////////////////

$(function() {
  if (signed_in()) {
    setTimeout(heartbeat, 10000);
  }
});

var heartbeat = function() {
  // store the current user's name
  user_name = $("#main_menu").attr("class");
  
  $.ajax( {
    type: "PATCH",
    url: "/users/" + user_name + "/heartbeat.js",
    success: function(response) {
      response;
    }
  });
  
  setTimeout(heartbeat, 10000);
};


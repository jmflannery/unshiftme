///////////////////////////////////
// acknowledge (read) message
///////////////////////////////////

var read_message = function() {
  if ($(this).hasClass("recieved") && $(this).hasClass("unread")) {
    var message_id = $(this).data("message_id");
     
    var user_name = $("#main_menu").attr("class");
    if (message_id) {
      $.ajax( {
        type: "PUT",
        url: "/users/" + user_name + "/messages/" + message_id,
        success: function(response) {
          response;
        }
      });
    }
  }
};

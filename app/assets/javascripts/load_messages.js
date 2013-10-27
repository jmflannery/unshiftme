///////////////////////////////////////////////
// Load messages
///////////////////////////////////////////////

var load_messages = function() {
  show_message_loading_icon();

  var user_name = $("#main_menu").attr("class");
  $.getJSON("/users/" + user_name + "/messages", function(data) {
    hide_message_loading_icon();

    $.each(data.messages, function(index, value) {
      if (value.attachment_url) {
        display_message(Mustache.to_html($('#attachment_template').html(), value), value.id);
      } else {
        display_message(Mustache.to_html($('#message_template').html(), value), value.id);
      }
    });
  });
}

$(function() {
  if (on_messaging_page()) {
    load_messages();
  }
});


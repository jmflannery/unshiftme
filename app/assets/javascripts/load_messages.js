///////////////////////////////////////////////
// Load messages
///////////////////////////////////////////////

var load_messages = function() {
  show_message_loading_icon();
  $.get("/messages.json", function(data) {
    hide_message_loading_icon();
    $.each(data, function(index, value) {
      if (value.view_class.search("owner") > 0) {
        readers = value.readers;
      } else {
        readers = "";
      }
      var html = build_message(value.sender, value.attachment_url, value.content, value.created_at, value.view_class, readers);
      display_message(html, value.id);
    });
  });
};

$(function() {
  if (on_messaging_page()) {
    load_messages();
  }
});


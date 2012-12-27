///////////////////////////////////////////////
// Load Transcript Messages
///////////////////////////////////////////////

var load_transcript_messages = function() {
//show_message_loading_icon();
  var ts_page = $('#transcript_show');
  var data = {};
  data["start_time"] = ts_page.data("startTime");
  data["end_time"] = ts_page.data("endTime");
  data["user_id"] = ts_page.data("user");
  data["workstation_id"] = ts_page.data("workstation");
  $.get("/messages.json", data, function(data) {
  //  hide_message_loading_icon();
    $.each(data, function(index, value) {
      var html = build_message(value.sender, value.attachment_id, value.content, value.created_at, value.view_class, value.readers);
      display_message(html, value.id);
    });
  });
};

$(function() {
  if (on_transcript_page()) {
    load_transcript_messages();
  }
});


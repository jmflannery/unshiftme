///////////////////////////////////////////////
// Load Transcript Messages
///////////////////////////////////////////////

function load_transcript_messages() {
  show_message_loading_icon();
  var ts_page = $('#transcript_page');
  $.get("/transcripts/" + ts_page.data("id") + ".json", function(data) {
    hide_message_loading_icon();
    $.each(data.messages, function(index, value) {
      display_message(Mustache.to_html($('#message_template').html(), value), value.id);
    });
  });
};

$(function() {
  if (on_transcript_page()) {
    load_transcript_messages();
  }
});


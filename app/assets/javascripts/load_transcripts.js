TranscriptLoader = function(username) {
  this.username = username;
};

TranscriptLoader.prototype = { 

  load_transcript: function() {
    MessageUtils.show_message_loading_icon();

    var ts_page = $('#transcript_page');
    var user_name = $("#main_menu").attr("class");
    var url = "/users/" + user_name + "/transcripts/" + ts_page.data("id") + ".json";

    $.get(url, function(data) {
      MessageUtils.hide_message_loading_icon();

      $.each(data.messages, function(index, value) {
        if (value.attachment_url) {
          MessageUtils.display_message(Mustache.to_html($('#attachment_template').html(), value), value.id);
        } else {
          MessageUtils.display_message(Mustache.to_html($('#message_template').html(), value), value.id);
        }
      });
    });
  }
};

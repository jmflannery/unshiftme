var Notifications = {

  messageReceivedHandler: function(data, channel) {
    this.beeper.beep();

    var template = data.attachment_url ? '#attachment_template' : '#message_template';
    display_new_message(Mustache.to_html($(template).html(), data), data.id);
  },

  acknowledgementReceivedHandler: function(data, channel) {
    var message = findMessage(data.message);
    $(".readers", message).html(data.readers);
  }
};

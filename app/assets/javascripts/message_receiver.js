MessageReceiver = function(username) {
  this.username = username;
  new VolumeSlider('#volume_slider', '#volume_button').setup();
  this.beeper = new Beeper('audio', '#slider');
};

MessageReceiver.prototype = {
  subscribe: function() {
    PrivatePub.subscribe("/messages/" + this.username, this.handler.bind(this));
  },

  handler: function(data, channel) {
    // play tone
    this.beeper.beep();

    // display the new message
    var template = data.attachment_url ? '#attachment_template' : '#message_template';
    display_new_message(Mustache.to_html($(template).html(), data), data.id);
  }
};

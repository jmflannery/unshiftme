MessageLoader = function(username) {
  this.username = username;
};

MessageLoader.prototype = {

  loadMessages: function() {
    this.show_message_loading_icon();

    $.getJSON("/users/" + this.user_name + "/messages", function(data) {
      this.hide_message_loading_icon();

      $.each(data.messages, function(index, value) {
        if (value.attachment_url) {
          MessageUtils.display_message(Mustache.to_html($('#attachment_template').html(), value), value.id);
        } else {
          MessageUtils.display_message(Mustache.to_html($('#message_template').html(), value), value.id);
        }
      });
    }.bind(this));
  },

  show_message_loading_icon: function() {
    $('#message_loading_icon').show();
  },

  hide_message_loading_icon: function() {
    $('#message_loading_icon').hide();
  }
};

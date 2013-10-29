MessageLoader = function(username) {
  this.username = username;
};

MessageLoader.prototype = {

  loadMessages: function() {
    MessageUtils.show_message_loading_icon();

    $.getJSON("/users/" + this.user_name + "/messages", function(data) {
      MessageUtils.hide_message_loading_icon();

      $.each(data.messages, function(index, value) {
        if (value.attachment_url) {
          MessageUtils.display_message(Mustache.to_html($('#attachment_template').html(), value), value.id);
        } else {
          MessageUtils.display_message(Mustache.to_html($('#message_template').html(), value), value.id);
        }
      });
    }.bind(this));
  },

  acknowledgeMessage: function() {
    var self = this;
    if ($(this).hasClass("recieved") && $(this).hasClass("unread")) {
      var message_id = $(this).data("message_id");

      if (message_id) {
        $.ajax({
          type: "PUT",
          url: "/users/" + self.username + "/messages/" + message_id,
          success: function(response) {
            response;
          }
        });
      }
    }
  },

  addAcknowledgementClickHandlers: function() {
    $('ul#message_list').on('click', 'li', this.acknowledgeMessage);
  }
};

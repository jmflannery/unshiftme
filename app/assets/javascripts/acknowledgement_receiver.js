AcknowledgementReceiver = function(username) {
  this.username = username;
};

AcknowledgementReceiver.prototype = {
  subscribe: function() {
    PrivatePub.subscribe("/readers/" + this.username, this.handler.bind(this));
  },

  handler: function(data, channel) {
    var message = findMessage(data.message);
    $(".readers", message).html(data.readers);
  }
};

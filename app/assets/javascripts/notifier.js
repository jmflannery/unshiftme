Notifier = function(username) {
  this.username = username;
};

Notifier.prototype = {

  subscribe: function(channel, callback) {
    PrivatePub.subscribe("/" + channel + "/" + this.username, callback.bind(this));
  }
};

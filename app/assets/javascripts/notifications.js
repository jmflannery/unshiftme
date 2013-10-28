var Notifications = {

  messageReceivedHandler: function(data, channel) {
    this.beeper.beep();

    var template = data.attachment_url ? '#attachment_template' : '#message_template';
    MessageUtils.display_new_message(Mustache.to_html($(template).html(), data), data.id);
  },

  acknowledgementReceivedHandler: function(data, channel) {
    var message = MessageUtils.find_message(data.message);
    $(".readers", message).html(data.readers);
  },

  workstationUserChangedHandler: function(data, channel) {
    var workstations = data.workstations.split(",");
    workstations.forEach(function(workstation) {
      var el = $("#recipient_selection_section #" + workstation);
      el.find("p.user").html("(" + data.name + ")");
    });
  }
};

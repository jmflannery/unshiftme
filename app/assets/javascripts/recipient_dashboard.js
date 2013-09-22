var RecipientDashboard = function(parent) {
  this.$parent = $(parent);
  this.$loading = this.$parent.find('#loading');
  this.$workstations = this.$parent.find('#workstations');
  this.setup();
};


RecipientDashboard.toggleAllButton = function() {
  var html = "<div id='toggle_all_workstations' class='recipient_workstation other last'><p id='msg_all_btn'></p></div>";
  return $(html).click(toggle_all_workstations);
};

RecipientDashboard.prototype = {
  
  setup: function() {
    this.hide_workstation_selection();
    this.show_workstation_loading_icon();
  },

  build: function() {
    var self = this;
    $.getJSON("/workstations", function(response) {
      $.each(response, function(index, value) {
        var html = Mustache.to_html($('#workstation_template').html(), value);   
        var $workstation = $(html).data("workstation_id", value.id).turnOff().click(toggle_recipient);
        self.$workstations.append($workstation);
      });
      self.$workstations.append(RecipientDashboard.toggleAllButton());
      
      self.build_user_workstation_info();
    });
  },

  build_user_workstation_info: function() {
    var user_name = $("#main_menu").attr("class");
    var self = this;
    $.getJSON("/users/" + user_name, function(response) {
      var msg_all_btn_text = "";
      var msg_all_btn_class = "";
      for (var i = 0; i < response.workstations.length; i++) {
        $("#" + response.workstations[i].name).addClass("mine").removeClass("off").removeClass("other");
      }
      for (var i = 0; i < response.recipient_workstations.length; i++) {
        $("#" + response.recipient_workstations[i].name).turnOn().data("recipient_id", response.recipient_workstations[i].recipient_id);
      }

      if (response.recipient_workstations.length == 6) {
        msg_all_btn_text = "Message</br>none";
        msg_all_btn_class = "none";
      } else {
        msg_all_btn_text = "Message</br>all";
        msg_all_btn_class = "all";
      }
      $("p#msg_all_btn").html(msg_all_btn_text).parent().addClass(msg_all_btn_class);

      self.hide_workstation_loading_icon();
      self.show_workstation_selection();
    });
  },

  hide_workstation_selection: function() {
    this.$workstations.hide();
  },

  show_workstation_loading_icon: function() {
    this.$loading.show();
  },

  hide_workstation_loading_icon: function() {
    this.$loading.hide();
  },

  show_workstation_selection: function() {
    this.$workstations.show();
  }
};

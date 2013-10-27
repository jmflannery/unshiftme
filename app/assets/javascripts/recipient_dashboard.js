var RecipientDashboard = function(parent, username) {
  this.$parent = $(parent);
  this.username = username;
  this.$loading = this.$parent.find('#loading');
  this.$workstations = this.$parent.find('#workstations');
  this.setup();
};

RecipientDashboard.prototype = {
  
  setup: function() {
    this.hide_workstation_selection();
    this.show_workstation_loading_icon();
  },

  done: function() {
    this.hide_workstation_loading_icon();
    this.show_workstation_selection();
  },

  build: function() {
    var self = this;
    $.getJSON("/workstations", function(response) {
      $.each(response.workstations, function(index, value) {
        var html = Mustache.to_html($('#workstation_template').html(), value);   
        var $workstation = $(html).data("workstation_id", value.id).turnOff().click(self.toggle_recipient);
        self.$workstations.append($workstation);
      });
      self.$workstations.append(self.toggleAllButton());
      
      self.build_user_workstation_info();
    });
    this.done();
  },

  build_user_workstation_info: function() {
    var self = this;
    $.getJSON("/users/" + this.username, function(response) {
      var msg_all_btn_text = "";
      var msg_all_btn_class = "";

      $.each(response.user.workstations, function(index, value) {
        $("#" + value.abrev).addClass("mine").removeClass("off").removeClass("other");
      });

      $.each(response.user.message_routes, function(index, value) {
        $("#" + value.workstation.abrev).turnOn().data("data-recipient-id", value.id);
      });

      // bug - hard coded 6, need to subtract the number of workstations
      // controlled by the user
      if (response.user.message_routes.length == 6) {
        msg_all_btn_text = "Message</br>none";
        msg_all_btn_class = "none";
      } else {
        msg_all_btn_text = "Message</br>all";
        msg_all_btn_class = "all";
      }
      $("p#msg_all_btn").html(msg_all_btn_text).parent().addClass(msg_all_btn_class);
    });
  },


  toggleAllButton: function() {
    var html = "<div id='toggle_all_workstations' class='recipient_workstation other last'><p id='msg_all_btn'></p></div>";
    return $(html).click(this.toggle_all_workstations);
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
  },

  toggle_recipient: function() {
    var state = $(this).onOrOff();
    
    if (state && state == "off") { 
      var workstation_id = $(this).data("workstation_id");

      if (workstation_id) {
        // POST - recipients#create
        $.ajax( {
          type: "POST", 
          url: "/message_routes",
          data: { "workstation_id": workstation_id },
          success: function(response) {
            response;
          }
        });
      }

    } else if (state && state == "on") {
      var recipient_id = $(this).data("data-recipient-id");
      
      if (recipient_id) {
        // DELETE - recipients#destroy
        $.ajax( {
          type: "POST", 
          url: "/message_routes/" + recipient_id,
          data: { _method: 'delete' },
          success: function(response) {
            response;
          }
        });
      }
    }
  },

  toggle_all_workstations: function() {
    $(this).toggleClass("all");
    $(this).toggleClass("none");

    if ($(this).hasClass("none")) {
      $(this).html("<p>Message</br>none</p>"); 

      // POST - recipients#create all
      $.ajax( {
        type: "POST", 
        url: "/message_routes",
        data: { "workstation_id": "all" },
        success: function(response) {
          response;
        }
      });
    } else {
      $(this).html("<p>Message</br>all</p>"); 

      // DELETE - workstations#destroy all
      $.ajax( {
        type: "POST", 
        url: "/message_routes/all",
        data: { _method: 'delete' },
        success: function(response) {
          response;
        }
      });
    }
  }
};

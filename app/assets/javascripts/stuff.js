///////////////////////////////////////////////
// Find a message list element by message id
///////////////////////////////////////////////

var findMessage = function(message_id) {
  var message = 0;
  $("#message_list li.message").each(function(index) {
    if ($(this).data("message_id") == message_id) {
      message = $(this);
    }
  });
  return message;
}

////////////////////////////////////////
// Get the user's id
////////////////////////////////////////

$(function() {
  user_name = $("#main_menu").attr("class");
  
});

////////////////////////////////////////
// Calculate Height
////////////////////////////////////////

// calculate_message_section_height
// resize the '#message_list_section' to be 68% of the window
var calculate_message_section_height = function() {
  height = $(window).outerHeight(true);
  outer_height = (height * 80) / 100;
  inner_height = (outer_height * 80) / 100;
  $('#content').height(outer_height);
  $('#message_list_section').height(inner_height);
  //$('#messages_section').scrollTo("max");
};

// resize on page load
$(calculate_message_section_height);

// resize on each browser resize by the user
$(function() {
  $(window).resize(calculate_message_section_height);
});

////////////////////////////////////////
// auto select jobs on signin page
////////////////////////////////////////

$(function() {
  // if on the sign on page 
  if ($("#signin_page").length > 0) {
    // user name field loses focus
    $("input#user_name").focusout(function(event) {
      name = event.target.value;
      if (name) { 
        // GET - sessions#new
        $.ajax( {
          type: "GET", 
          url: "/session/new.json",
          data: { "user": name },
          success: function(response) {
            if (response.normal_workstations) {
              $("input:checkbox").removeAttr("checked");
              var normal_workstations = response.normal_workstations.split(",");
              var i;
              for (i = 0; i < normal_workstations.length; i++) {
                $("input#" + normal_workstations[i]).prop("checked", true);
              }
            }
          }
        });
      }
    });
  }
});

// RecipientDashboard
$(function() {
  if (on_messaging_page()) {
    var recipient_dashboard = new RecipientDashboard('#recipient_selection_section');
    recipient_dashboard.build();
  }
});

///////////////////////////////////
// toggle recipient
///////////////////////////////////

var toggle_recipient = function() {
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
    var recipient_id = $(this).data("recipient_id");
    
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
};

///////////////////////////////////
// Toggle all (workstations)
//////////////////////////////////

var toggle_all_workstations = function() {
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

///////////////////////////////////
// acknowledge (read) message
///////////////////////////////////

var read_message = function() {
  if ($(this).hasClass("recieved") && $(this).hasClass("unread")) {
    var message_id = $(this).data("message_id");
     
    if (message_id) {
      $.ajax( {
        type: "PUT",
        url: "/messages/" + message_id,
        success: function(response) {
          response;
        }
      });
    }
  }
};

////////////////////////////////////
// create a user_name
////////////////////////////////////

var name_user = function() {
  var user_name_input = $('input#user_user_name');
  if (!user_name_input.val()) {
    var first_name = $('input#user_first_name').val();
    var middle_initial = $('input#user_middle_initial').val();
    var last_name = $('input#user_last_name').val();
    var user_name = "";
    if (first_name && first_name.length >= 1) {
      user_name += first_name[0];
    }
    if (middle_initial && middle_initial.length >= 1) {
      user_name += middle_initial[0];
    }
    if (last_name && last_name.length >= 1) {
      user_name += last_name;
    }
    if (user_name) {
      user_name_input.val(user_name.toLowerCase());
    }
  }
};

$(function() {
  $('input#user_user_name').click(name_user).focusin(name_user);
  $('label[for=user_user_name]').click(name_user);
});


////////////////////////////////////
// Workstation radio buttons
////////////////////////////////////
$(function() {
  $("#td_workstations input").click(function() {
    $("#ops_workstations input").removeAttr("checked");
  });
  $("input#YDCTL").click(function() {
    $("#td_workstations input").removeAttr("checked");
    $("input#YDMSTR").removeAttr("checked");
    $("input#GLHSE").removeAttr("checked");
  });
  $("input#YDMSTR").click(function() {
    $("#td_workstations input").removeAttr("checked");
    $("input#YDCTL").removeAttr("checked");
    $("input#GLHSE").removeAttr("checked");
  });
  $("input#GLHSE").click(function() {
    $("#td_workstations input").removeAttr("checked");
    $("input#YDCTL").removeAttr("checked");
    $("input#YDMSTR").removeAttr("checked");
  });
});

///////////////////////////////////
// show the most recent message
///////////////////////////////////

//$(function() {
//  if ($("#messages_section").length > 0) {  
//    $('#messages_section').scrollTo("max");
//  }
//});

///////////////////////////////////////////////
// Loading icon
///////////////////////////////////////////////

// messages
var show_message_loading_icon = function() {
  $('#message_loading_icon').show();
}

var hide_message_loading_icon = function() {
  $('#message_loading_icon').hide();
}

///////////////////////////////////////////////
// message recieve handler 
///////////////////////////////////////////////

$(function() {
  // store the current user's name
  user_name = $("#main_menu").attr("class");

  new VolumeSlider('#volume_slider', '#volume_button').setup();

  var beeper = new Beeper('audio', '#slider');

  // register callback
  PrivatePub.subscribe("/messages/" + user_name, function(data, channel) {

    // play tone
    beeper.beep();

    // display the new message 
    var template = data.attachment_url ? '#attachment_template' : '#message_template';
    display_new_message(Mustache.to_html($(template).html(), data), data.id);

    // scroll to last message 
    //if (data.chat_message) {
    //  $('#messages_section').scrollTo("max");
    //}
  });
});

///////////////////////////////////////////////
// user signin/signout handler
///////////////////////////////////////////////

$(function() {
  // store the current user's name
  user_name = $("#main_menu").attr("class");

  // register callback
  PrivatePub.subscribe("/workstations/" + user_name, function(data, channel) {
    var workstations = data.workstations.split(",");
    workstations.forEach(function(workstation) {
      var el = $("#recipient_selection_section #" + workstation);
      el.find("p.user").html("(" + data.name + ")");
    });
  });
});

///////////////////////////////////////////////
// message read handler
///////////////////////////////////////////////

$(function() {
  // store the current user's name
  user_name = $("#main_menu").attr("class");

  // register callback
  PrivatePub.subscribe("/readers/" + user_name, function(data, channel) {
    message = findMessage(data.message);
    $(".readers", message).html(data.readers);
  });
});


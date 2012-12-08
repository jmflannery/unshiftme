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

/////////////////////////////////////////
// on messaging page?
////////////////////////////////////////

var on_messaging_page = function() {
  var messaging_page = false;
  if ($("#messages_section").length > 0) {
    messaging_page = true;
  }
  return messaging_page;
};

/////////////////////////////////////////
// on transcript show page?
////////////////////////////////////////

var on_transcript_page = function() {
  var transcript_page = false;
  if ($("#transcript_show").length > 0) {
    transcript_page  = true;
  }
  return transcript_page; 
};

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
  if ($("#signin").length > 0) {
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

/////////////////////////////////////////
// create the workstation html elements
/////////////////////////////////////////

// get the workstation data
var build_workstation_buttons = function() {
  hide_workstation_selection();
  show_workstation_loading_icon();
  var workstation_section = $('#recipient_workstation_selection');
  var html = "";
  $.get("/workstations.json", function(response) {
    for (var i = 0; i < response.length; i++) {
      var class_name = "recipient_workstation";
      if (i == 0) {
        class_name += " first";
      }
      var html = "<div id=" + response[i].name + " class='" + class_name + "' >";
      html += "<p>" + response[i].long_name + "</p>";
      if (response[i].user_name && response[i].user_name.length > 0) {
        html += "<p><span id=user_at_" + response[i].name + ">(" + response[i].user_name + ")</span></p>";
      } else {
        html += "<p><span id=user_at_" + response[i].name + ">(vacant)</span></p>"
      }
      html += "</div>";
      var workstation = $(html).data("workstation_id", response[i].id).turnOff().click(toggle_recipient);
      workstation_section.append(workstation);
    }
    html = "<div id='toggle_all_workstations' class='recipient_workstation last all'><p>Message</br>all</p></div>";
    var toggle_all_button = $(html).click(toggle_all_workstations);
    workstation_section.append(toggle_all_button);
    
    build_user_workstation_info();
  });
};

// get the user data
var build_user_workstation_info = function() {
  var workstation_section = $('#recipient_workstation_selection');
  var user_name = $("#main_menu").attr("class");
  $.get("/users/" + user_name + ".json", function(response) {
    for (var i = 0; i < response.workstations.length; i++) {
      $("#" + response.workstations[i].name).addClass("mine").removeClass("off");
    }
    for (var i = 0; i < response.recipient_workstations.length; i++) {
      $("#" + response.recipient_workstations[i].name).turnOn().data("recipient_id", response.recipient_workstations[i].recipient_id);
    }
    hide_workstation_loading_icon();
    show_workstation_selection();
  });
};

$(function() {
  if (on_messaging_page()) {
    build_workstation_buttons();
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

var read_message = function(message_id) {
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

$(function() {
  $("li.message.recieved.unread").click(read_message);
});

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

///////////////////////////////////
// Upload Section
///////////////////////////////////

var expand_upload_section = function() {
  $('#upload_button').hide();
  $('#messages_section').animate({
    width: "62%"
  }, 'fast', 'swing', function() {
    $('#upload').css("width", "17%");
    $("#upload_close_button").fadeIn();
    $('#outer_upload_section').fadeIn('slow');
    $("#msg_input input[type='text']").css("width", "97%");
  });
};

var minimize_upload_section = function() {
  $("#msg_input input[type='text']").css("width", "93.4%");
  $("#upload_close_button").hide();
  $('#outer_upload_section').fadeOut('fast', function() {
    $('#upload').css("width", "0.6%");
    $('#upload_button').delay(100).fadeIn('slow');
    $('#messages_section').animate({width: "80%"}, 100, 'linear');
  });
};

var toggle_upload_section = function() {
  if ($("#outer_upload_section").is(":visible")) {
    minimize_upload_section();
  } else {
    expand_upload_section();
  }
};

$(function() {
  $("#outer_upload_section").hide();
  $("#upload_close_button").hide();
  $("form#new_attachment").hide().fileupload();
  $('#attach_button').click(toggle_upload_section)
  $('#upload_xicon').click(toggle_upload_section)
});

//////////////////////////////////////////////
// message upload 
//////////////////////////////////////////////

//$(function() {
//  if ($("#messages_section").length > 0) {
//    var uploader = new qq.FileUploader({
//        // pass the dom node (ex. $(selector)[0] for jQuery users)
//        element: document.getElementById('file-uploader'),
//        // path to server-side upload script
//        action: '/attachments.js'
//    });
//  }
//});

///////////////////////////////////////////////
// Load messages
///////////////////////////////////////////////

var load_messages = function() {
  show_message_loading_icon();
  $.get("/messages.json", function(data) {
    hide_message_loading_icon();
    $.each(data, function(index, value) {
      if (value.view_class.search("owner") > 0) {
        readers = value.readers;
      } else {
        readers = "";
      }
      var html = build_message(value.sender, value.attachment_url, value.content, value.created_at, value.view_class, readers);
      display_message(html, value.id);
    });
  });
};

$(function() {
  if (on_messaging_page()) {
    load_messages();
  }
});

///////////////////////////////////////////////
// Load Transcript Messages
///////////////////////////////////////////////

var load_transcript_messages = function() {
//show_message_loading_icon();
  var ts_page = $('#transcript_show');
  var data = {};
  data["start_time"] = ts_page.data("startTime");
  data["end_time"] = ts_page.data("endTime");
  data["user_id"] = ts_page.data("user");
  data["workstation_id"] = ts_page.data("workstation");
  $.get("/messages.json", data, function(data) {
  //  hide_message_loading_icon();
    $.each(data, function(index, value) {
      var html = build_message(value.sender, value.attachment_id, value.content, value.created_at, value.view_class, value.readers);
      display_message(html, value.id);
    });
  });
};

$(function() {
  if (on_transcript_page()) {
    load_transcript_messages();
  }
});

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

// workstations
var show_workstation_loading_icon = function() {
  $('#workstation_loading_icon').show();
}

var hide_workstation_loading_icon = function() {
  $('#workstation_loading_icon').hide();
}

var show_workstation_selection = function() {
  $('#recipient_workstation_selection').show();
}

var hide_workstation_selection = function() {
  $('#recipient_workstation_selection').hide();
}

///////////////////////////////////////////////
// message recieve handler 
///////////////////////////////////////////////

$(function() {
  // store the current user's name
  user_name = $("#main_menu").attr("class");

  // register callback
  PrivatePub.subscribe("/messages/" + user_name, function(data, channel) {
    // play tone
    $('#tone')[0].innerHTML = "<embed src=/assets/soft_chime_beep.mp3 hidden=true autostart=true loop=false>";

    // clear message text field
    $("input#message_content").val("");

    // create the new message html 
    var html = build_message(data.sender, data.attachment_url, data.chat_message, data.timestamp, "message recieved unread", ""); 
    
    // display the new message 
    display_new_message(html, data.message_id);

    // show the sending workstation(s) as recipient(s)
    for (var i = 0; i < data.recipient_ids.length; i++) {
      if (data.recipient_ids[i] > 0) {
        selector = "#" + data.from_workstations[i] + ".recipient_workstation.off";
        $(selector).turnOn().data("recipient_id", data.recipient_ids[i]);
      }
    }

    // scroll to last message 
    //if (data.chat_message) {
    //  $('#messages_section').scrollTo("max");
    //}
  });
});

var build_message = function(sender, attachment_url, content, timestamp, view_class, readers) {
  var html = "<li class='" + view_class + "'>" +
              "<div class='left-side'>" +
                "<div class='sender'>" +
                  "<p>" + sender + "</p>" +
                "</div>" + 
                "<div class='content'>";

                if (attachment_url) {
                  html += "<a href='" + attachment_url + "'>" + content + "</a>";
                } else {
                  html += "<p>" + content + "</p>";
                }
                html += "</div>" +

              "</div>" +
              "<div class='right-side'>" +
                "<div class='timestamp'>" +
                  "<p>" + timestamp + "</p>" +
                "</div>" +
                "<div class='readers'>" +
                  readers +
                "</div>" +
              "</div>" +
            "</li>";
                
  return html;
};

var display_new_message = function(message_html, message_id) {
  message_list_item = $("li.message:first-child");
  var message = $(message_html).data("message_id", message_id).click(read_message);
  if (message_list_item[0]) {
    message_list_item.before(message);
  } else {
    $("ul#message_list").html(message);
  }
};

var display_message = function(message_html, message_id) {
  message_list_item = $("li.message:last-child");
  var message = $(message_html).data("message_id", message_id).click(read_message);
  if (message_list_item[0]) {
    message_list_item.after(message);
  } else {
    $("ul#message_list").html(message);
  }
};

///////////////////////////////////////////////
// user signin/signout handler
///////////////////////////////////////////////

$(function() {
  // store the current user's name
  user_name = $("#main_menu").attr("class");

  // register callback
  PrivatePub.subscribe("/workstations/" + user_name, function(data, channel) {
    var workstations = data.workstations.split(",");
    for (var i = 0; i < workstations.length; i++) {
      var selector = "#user_at_" + workstations[i];
      $(selector).html("(" + data.name + ")");
    }
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
    $(".right-side .readers", message).html(data.readers);
  });
});


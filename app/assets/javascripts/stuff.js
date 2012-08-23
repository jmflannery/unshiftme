///////////////////////////////////////////////
// Find a message list element by message id
///////////////////////////////////////////////

findMessage = function(message_id) {
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
// heartbeat
////////////////////////////////////////

//$(function() {
//  if ($('#content').length > 0) {
//    setTimeout(heartbeat, 20000);
//  }
//});

var heartbeat = function() {
  // store the current user's name
  user_id = $("#content").attr("class");
  
    $.ajax( {
      type: "PUT",
      url: "/users/" + user_id + ".js",
      success: function(response) {
        response;
      }
    });
    
    setTimeout(heartbeat, 20000);
};

////////////////////////////////////////
// Calculate Height
////////////////////////////////////////

// calculate_message_section_height
// resize the '#messages_section' to be 68% of the window
var calculate_message_section_height = function() {
  height = $(window).outerHeight(true);
  outer_height = (height * 80) / 100;
  inner_height = (outer_height * 75) / 100;
  $('#content').height(outer_height);
  $('#messages_section').height(inner_height);
  //$('#messages_section').scrollTo("max");
};

// resize on page load
$(function() {
  calculate_message_section_height();
});

// resize on each browser resize by the user
$(function() {
  $(window).resize(calculate_message_section_height);
});

////////////////////////////////////////
// hide_available_users()
////////////////////////////////////////

var hide_available_users = function() {
  $("#recipient_selection_section").html("<a href='/users' data-remote='true' format='js' id='users_button'>Add Available Users</a>");
};

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
  var workstation_section = $('#recipient_workstation_selection');
  var html = "";
  if (workstation_section.length > 0) {
    $.ajax( {
      type: "GET",
      url: "/workstations.json",
      success: function(response) {
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
      }
    });
  }
};

// get the user data
var build_user_workstation_info = function() {
  var workstation_section = $('#recipient_workstation_selection');
  var user_name = $("#main_menu").attr("class");
  if (workstation_section.length > 0) {
    $.ajax( {
      type: "GET",
      url: "/users/" + user_name + ".json",
      success: function(response) {
        for (var i = 0; i < response.workstations.length; i++) {
          $("#" + response.workstations[i].name).addClass("mine").removeClass("off");
        }
        for (var i = 0; i < response.recipient_workstations.length; i++) {
          $("#" + response.recipient_workstations[i].name).turnOn().data("recipient_id", response.recipient_workstations[i].recipient_id);
        }
      }
    });
  }
};

$(build_workstation_buttons);
$(build_user_workstation_info);

///////////////////////////////////
// add recipient
///////////////////////////////////

var toggle_recipient = function() {
  var state = $(this).onOrOff();
  
  if (state && state == "off") { 
    var workstation_id = $(this).data("workstation_id");

    if (workstation_id) {
      // POST - recipients#create
      $.ajax( {
        type: "POST", 
        url: "/recipients",
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
        url: "/recipients/" + recipient_id,
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
      url: "/recipients",
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
      url: "/recipients/all",
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

$(function() {
  $('a#attach_button').click(function() {
    upload_section = $('#upload_section');
    height = upload_section.outerHeight(true);
    messages_section = $('#messages_section');
    upload_section.toggle();
    upload_button = $('a#attach_button');

    if (upload_section.is(":hidden")) {
      messages_section.css("height", "+=" + height);
      $('input[type="file"]').val("");
      upload_button.text("Show File Uploader");
    } else {
      messages_section.css("height", "-=" + height);
      upload_button.text("Hide File Uploader");
    }
  });
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
    var html ="<li class='message recieved unread'>" +
            "<ul class='inner_message'>" +
              "<li>" +
                "<div class='message_sender'>" +
                  "<p>" + data.sender + "</p>" +
                "</div>" + 
                "<div class='message_timestamp'>" +
                  "<p>" + data.timestamp + "</p>" +
                "</div>" +
              "</li>" +
              "<li>" +
                "<div class='message_content'>";
    
    if (data.attachment_url) {
      html += "<a href='" + data.attachment_url + "'>" + data.chat_message + "</a>";
    } else {
      html += "<p>" + data.chat_message + "</p>";
    }
     
    html += "</div>" +
           "</li>" +
         "</ul>" +  
       "</li>"; 
    
    // display the new message 
    display_new_message(html, data.message_id);

    // add click handler to new message element
    $("li.message.recieved.unread").click(read_message);

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

var display_new_message = function(message_html, message_id) {
  message_list_item = $("li.message:first-child");
  var message = $(message_html).data("message_id", message_id);
  if (message_list_item[0]) {
    message_list_item.before(message);
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
    console.log("message: " + data.message); 
    selector = "li.message.owner." + data.message + " ul.inner_message li .read_by";
    console.log(selector);
    $(selector).html(data.readers);
  });
});

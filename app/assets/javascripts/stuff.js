// Returns the array of class names
$.fn.getClassNames = function() {
  var klasses = $(this).attr("class");
  if (klasses != null) {
    return klasses.split(" ");
  } else {
    return [];
  }
};

// returns true if the passed in string is a class of $(this)
$.fn.hasClass = function(klas) {
  var has = false;
  var klasses = $(this).getClassNames();
  for (i = 0; i < klasses.length; i += 1) {
    if (klasses[i] == klas) {
      has = i;
      break;
    }
  }
  return has;
};

// returns the first class found that can be parsed to int, or false if none found
$.fn.getNumberClass = function() {
  var num = false;
  var klasses = $(this).getClassNames();
  for (i = 0; i < klasses.length; i += 1) {
    if (!isNaN(klasses[i])) {
      num = klasses[i];
      break;
    }
  }
  return num;
};

// returns "on" if the given element has the class "on"
// returns "off" if the given element has the class "off"
// returns false if class "on" or "off" is not found on given element
// returns fasle if both "on" and "off" are found
$.fn.onOff = function() {
  var on = $(this).hasClass("on");
  var off = $(this).hasClass("off");
  if (on && !off) {
    status = "on";
  } else if (off && !on) {
    status = "off";
  } else {
    status = false;
  }
  return status;
};

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
  calculated_height = (height * 68) / 100;  
  $('#messages_section').height(calculated_height);
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
            if (response.normal_desks) {
              $("input:checkbox").removeAttr("checked");
              var normal_desks = response.normal_desks.split(",");
              var i;
              for (i = 0; i < normal_desks.length; i++) {
                $("input#" + normal_desks[i]).prop("checked", true);
              }
            }
          }
        });
      }
    });
  }
});

///////////////////////////////////
// add recipient
///////////////////////////////////

var toggle_recipient = function() {
  state = $(this).onOff();
  
  if (state && state == "off") { 
    var innerEl = $(this).find(".recipient_desk_id");
    desk = $(innerEl).getNumberClass();

    if (desk) {
      // POST - recipients#create
      $.ajax( {
        type: "POST", 
        url: "/recipients",
        data: { "desk_id": desk },
        success: function(response) {
          response;
        }
      });
    }

  } else if (state && state == "on") {
    var recipient_index = $(this).getNumberClass();
    
    if (recipient_index) {
      // DELETE - desks#destroy
      $.ajax( {
        type: "POST", 
        url: "/recipients/" + recipient_index,
        data: { _method: 'delete' },
        success: function(response) {
          response;
        }
      });
    }
  }
};

$(function() {
  $(".recipient_desk.on").click(toggle_recipient);
  $(".recipient_desk.off").click(toggle_recipient);
});

///////////////////////////////////
// Toggle all (desks)
//////////////////////////////////

var toggle_all_desks = function() {
  $(this).toggleClass("all");
  $(this).toggleClass("none");

  if ($(this).hasClass("none")) {
    $(this).html("<p>Message</br>none</p>"); 

    // POST - recipients#create all
    $.ajax( {
      type: "POST", 
      url: "/recipients",
      data: { "desk_id": "all" },
      success: function(response) {
        response;
      }
    });
  } else {
    $(this).html("<p>Message</br>all</p>"); 

    // DELETE - desks#destroy all
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

$(function() {
  $("#toggle_all_desks").click(toggle_all_desks);
});

///////////////////////////////////
// acknowledge (read) message
///////////////////////////////////

var read_message = function(message_id) {
  var classes = $(this).attr("class").split(" ");
  var i;
  var message_id = 0;
  for (i = 0; i < classes.length; i += 1) {
    if (classes[i].indexOf("msg-") != -1) {
      var klas = classes[i].substring(4, classes[i].length);
      message_id = parseInt(klas);
    }
  }

  if (message_id) {
    $.ajax( {
      type: "PUT",
      url: "/messages/" + message_id,
      success: function(response) {
        response;
      }
    });
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
// Desk radio buttons
////////////////////////////////////
$(function() {
  $("#td_desks input").click(function() {
    $("#ops_desks input").removeAttr("checked");
  });
  $("input#YDCTL").click(function() {
    $("#td_desks input").removeAttr("checked");
    $("input#YDMSTR").removeAttr("checked");
    $("input#GLHSE").removeAttr("checked");
  });
  $("input#YDMSTR").click(function() {
    $("#td_desks input").removeAttr("checked");
    $("input#YDCTL").removeAttr("checked");
    $("input#GLHSE").removeAttr("checked");
  });
  $("input#GLHSE").click(function() {
    $("#td_desks input").removeAttr("checked");
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
    html ="<li class='" + data.view_class + "'>" +
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
    display_new_message(html);

    // add click handler to new message element
    $("li.message.recieved.unread").click(read_message);

    // show the sending desk(s) as recipient(s)
    for (var i = 0; i < data.recipient_ids.length; i++) {
      if (data.recipient_ids[i] > 0) {
        selector = "#" + data.from_desks[i] + ".recipient_desk.off";
        $(selector).removeClass("off").addClass(data.recipient_ids[i].toString()).addClass("on");
      }
    }

    // scroll to last message 
    //if (data.chat_message) {
    //  $('#messages_section').scrollTo("max");
    //}
  });
});

var display_new_message = function(message_html) {
  message_list_item = $("li.message:first-child");
  if (message_list_item[0]) {
    message_list_item.before(message_html);
  } else {
    $("ul#message_list").html(message_html);
  }
};

///////////////////////////////////////////////
// user signin/signout handler
///////////////////////////////////////////////

$(function() {
  // store the current user's name
  user_name = $("#main_menu").attr("class");

  // register callback
  PrivatePub.subscribe("/desks/" + user_name, function(data, channel) {
    var desks = data.desks.split(",");
    for (var i = 0; i < desks.length; i++) {
      selector = "#" + desks[i] + " .recipient_user_id"
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

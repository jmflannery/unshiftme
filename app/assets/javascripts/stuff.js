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

///////////////////////////////////
// add recipient
///////////////////////////////////

//TODO: refactor, too ugly
var toggle_recipient = function() {
  $(this).toggleClass("off");
  $(this).toggleClass("on");
  var classes = $(this).getClassNames();

  var i;
  var status_index = -1;
  var recipient_index = -1;
  for (i = 0; i < classes.length; i += 1) {
    if (!isNaN(classes[i])) {
      recipient_index = i;
    } else if (classes[i] == "on" || classes[i] == "off") {
      status_index = i;
    }
  }
 
  if (status_index > -1) { 
    if (classes[status_index] == "on") {

      var innerEl = $(this).find(".recipient_desk_id");
      var innerClasses = innerEl.attr('class').split(" ");
      var desk = 0;
      if (innerClasses[1]) {
        if (!isNaN(innerClasses[1])) {
          desk = parseInt(innerClasses[1]);
        }
      }  

      var data = { "desk_id": desk };
      
      // POST - recipients#create
      $.ajax( {
        type: "POST", 
        url: "/recipients",
        data: data,
        success: function(response) {
          response;
        }
      });

    } else if (classes[status_index] == "off") {
      
      var data = { _method: 'delete' };

      // DELETE - desks#destroy
      if (classes[recipient_index] && !isNaN(classes[recipient_index]) && classes[recipient_index] > 0) {
        $.ajax( {
          type: "POST", 
          url: "/recipients/" + parseInt(classes[recipient_index]),
          data: data,
          success: function(response) {
            response;
          }
        });
      }
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

  if ($(this).hasClass("all")) {
    $(this).html("<p>Message</br>all</p>"); 

    var data = { "desk_id": "all" };
    
    // POST - recipients#create
    $.ajax( {
      type: "POST", 
      url: "/recipients",
      data: data,
      success: function(response) {
        response;
      }
    });
  } else {
    $(this).html("<p>Message</br>none</p>"); 
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
    var clas = parseInt(classes[i]);
    if (!isNaN(clas)) {
      message_id = clas;
      console.log(clas);
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
                  "<p>" + data.from_desks + " (" + data.sender + ")</p>" +
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

    // show the sending desk as a recipient
    var desks = data.from_desks.split(",");
    for (var i = 0; i < desks.length; i++) {
      selector = "#" + desks[i] + ".recipient_desk.off";
      $(selector).removeClass("off").addClass("on").addClass(data.recipient_id);
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

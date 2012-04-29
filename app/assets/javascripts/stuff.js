// Returns the array of class names
$.fn.getClassNames = function() {
  var name = this.attr("className");
  if (name != null) {
    return name.split(" ");
  } else {
    return [];
  }
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
  $("#select_desk input").click(function() {
    console.log($(this).val());
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
  user_name = $("#user_name_section").attr("class");

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

    // display/refresh the recipients and online users
    $.get(
      "/recipients",
      function(response) {
        response;
      }
    );

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
// message read handler
///////////////////////////////////////////////

$(function() {
  // store the current user's name
  user_name = $("#user_name_section").attr("class");

  // register callback
  PrivatePub.subscribe("/readers/" + user_name, function(data, channel) {
    console.log("message: " + data.message); 
    selector = "li.message.owner." + data.message + " ul.inner_message li .read_by";
    console.log(selector);
    $(selector).html(data.readers);
  });
});

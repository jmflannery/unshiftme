/////////////////////////////////
// Round the corners (even ie!)
/////////////////////////////////

$(function() {
  //$('.button').corner();
  //$('#users_show_top').corner("6px top");
  //$('#users_show_bottom').corner("6px bottom");
  //$('#messages_section').corner("6px");
  //$('td#send_to').corner("6px");
  //$('#edit_user').corner("6px");
});

//////////////////////////
// Open User List Dialog
//////////////////////////

$.fx.speeds._default = 400;
$(function() {
  $('#dialog').dialog({
    autoOpen: false,
    show: "drop",
    hide: "drop",
    width: 350
  });
});

////////////////////////////
// X button image rollover
////////////////////////////

var x_button_roll_in = function() {
  $(this).attr("src", "/assets/red_x.png");
  console.log("hovering in!!!");
};

var x_button_roll_out = function() {
  console.log("hover boarding out!");
  $(this).attr("src", "/assets/grey_x.png");
};

$(function() {
  $('img.x_button').hover(x_button_roll_in, x_button_roll_out);
});

///////////////////////////////////
// Upload Section
///////////////////////////////////

$(function() {
  $('a#attach_button').click(function() {
    upload_section = $('#upload_section');
    messages_section = $('#messages_section');
    upload_section.toggle();
    if (upload_section.is(":hidden")) {
      messages_section.css("height", "+=45");
      $('input[type="file"]').val("");
    } else {
      messages_section.css("height", "-=45");   
    }
  });
});

///////////////////////////////////
// Poll Server for more Messages
///////////////////////////////////

$(function() {
  if ($("#messages_section").length > 0) {  
    setTimeout("pollForMessages('Auto Poll')", 2000);
  }
});

var pollForMessages = function(message) {
  console.log(message);
  var id = $('#user_name_section').attr("class");
  $.getScript("/messages.js?user_id=" + id);
  var f = "pollForMessages('auto poll')";
  setTimeout(f, 2000);
};

var getMessages = function(message) {
  console.log(message);
  var id = $('#user_name_section').attr("class");
  $.getScript("/messages.js?user_id=" + id); 
};

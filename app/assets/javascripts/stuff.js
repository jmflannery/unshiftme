//////////////////////////
// Page Links (not used)
//////////////////////////

$(function() {
  $('#nav ul li a.current').removeClass("current");
  var title = $(this).attr("title");
  if (title == "About") {
    $('#nav ul li a#link1').addClass("current");
  } else if (title == "Features") {
    $('#nav ul li a#link2').addClass("current");
  } else if (title == "Technology") {
    $('#nav ul li a#link3').addClass("current");
  }
});

/////////////////////////////////
// Round the corners (even ie!)
/////////////////////////////////

$(function() {
  $('.button').corner();
  //$('#users_show_top').corner("6px top");
  //$('#users_show_bottom').corner("6px bottom");
  $('#messages_section').corner("6px");
  $('td#send_to').corner("6px");
  $('#edit_user').corner("6px");
});

//////////////////////////
// Open User List Dialog
//////////////////////////

$.fx.speeds._default = 500;
$(function() {
  $('#dialog').dialog({
    autoOpen: false,
    show: "drop",
    hide: "drop"
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

///////////////////////////////////
// Poll Server for more Messages
///////////////////////////////////

$(function() {
  if ($("#messages_section").length > 0) {  
    setTimeout("updateMessages('Auto Poll')", 2000);
  }
});

function updateMessages(message) {
  console.log(message);
  //var after = $("tr.message:last-child").attr("data-time"); 
  //if (after == undefined) {
  //  after = $("#messages").attr("data-start");
  //}
  var id = $('#user_name_section').attr("class");
  $.getScript("/messages.js?user_id=" + id);
  var f = "updateMessages('auto poll')";
  setTimeout(f, 2000);
}

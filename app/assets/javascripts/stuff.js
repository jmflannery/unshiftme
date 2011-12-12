// Page Links
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

// Round the corners (even ie!)
$(function() {
  $('.button').corner();
  $('#users_show_top').corner("6px top");
  $('#users_show_bottom').corner("6px bottom");
  $('#sign_up').corner("6px");
  $('#sign_in_out').corner("6px");
  $('#edit_user').corner("6px");
});

// Open User List Dialog
//$.fx.speeds._default = 1000;
$(function() {
  $('#dialog').dialog({
    autoOpen: false,
    show: "blind",
    hide: "explode"
  });
});

//$(function() {
//  $('#users_link').click(function() {
//    $('#dialog').dialog("open");
//    return false;
//  });
//});

// Poll Server for more Messages
$(function() {
  if ($("#messages").length > 0) {  
    setTimeout("updateMessages('Auto Poll')", 2000);
  }
});

function updateMessages(message) {
  console.log(message);
  var after = $("tr.message:last-child").css("color", "#f5e2a9").attr("data-time");
  //if (after == undefined) {
  //  after = $("#messages").attr("data-start");
  //}
  $.getScript("/messages.js?after=" + after);
  var f = "updateMessages('auto poll')";
  setTimeout(f, 2000);
}

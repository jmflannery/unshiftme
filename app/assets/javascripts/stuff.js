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
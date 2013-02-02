var expand_upload_section = function() {
  $('#upload_button').fadeOut();
  $('#messages_section').animate({
    width: "64%"
  }, 'slow', function() {
    $('#upload').fadeIn('slow');
    $("#upload_close_button").fadeIn('slow');
  });
};

var minimize_upload_section = function() {
  $("#upload_close_button").fadeOut();
  $('#upload').fadeOut('fast', function() {
    $('#upload_button').delay(100).fadeIn('slow');
    $('#messages_section').animate({width: "83%"}, 'slow');
  });
};

var toggle_upload_section = function() {
  if ($("#upload").is(":visible")) {
    minimize_upload_section();
  } else {
    expand_upload_section();
  }
};

$(function() {
  $("#upload").hide();
  $("#upload_close_button").hide();
  $("form#new_attachment").hide().fileupload();
  $('#attach_button').click(toggle_upload_section)
  $('#upload_xicon').click(toggle_upload_section)
});


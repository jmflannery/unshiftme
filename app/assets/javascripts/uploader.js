var expand_upload_section = function() {
  $('#upload').slideDown();
  $("#upload_close_button").fadeIn();
};

var minimize_upload_section = function() {
  $("#upload_close_button").fadeOut();
  $('#upload').slideUp();
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
  $("form#new_attachment").fileupload();
  $('#attach_button').click(toggle_upload_section)
  $('#upload_xicon').click(toggle_upload_section)
});

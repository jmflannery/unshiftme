///////////////////////////////////
// Recipient User Selection
///////////////////////////////////

var toggleRecipientSelectionSection = function() {
  recipient_selection_section = $('#recipient_selection_section');
  
  recipient_selection_section.toggle();
  recipient_selection_section.toggleClass("visible");

  if (recipient_selection_section.is(":hidden")) {
    $('#messages_section').css("height", "+=220");
  } else {
    $('#messages_section').css("height", "-=220");   
  }

  $('#messages_section').scrollTo("max");
};

$(function() {
  $('#recipient_selection_section').hide();
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

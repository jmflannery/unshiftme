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
// Recipient User Selection
///////////////////////////////////

var toggleRecipientSelectionSection = function() {
  recipient_selection_section = $('#recipient_selection_section');
  
  recipient_selection_section.toggle();
  recipient_selection_section.toggleClass("visible");

  if (recipient_selection_section.is(":hidden")) {
    $('#messages_section').css("height", "+=200");
  } else {
    $('#messages_section').css("height", "-=200");   
  }
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

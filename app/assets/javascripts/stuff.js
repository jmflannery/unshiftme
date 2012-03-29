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
// show the most recent message
///////////////////////////////////

$(function() {
  if ($("#messages_section").length > 0) {  
    $('#messages_section').scrollTo("max");
  }
});

///////////////////////////////////
// Tone
///////////////////////////////////

$(function() {
  //$('#tone')[0].innerHTML = "<embed src=/assets/soft_chime_beep.mp3 hidden=true autostart=true loop=false>";
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

//////////////////////////////////////////////
//
//////////////////////////////////////////////

$(function() {
  if ($("#messages_section").length > 0) {
    var uploader = new qq.FileUploader({
        // pass the dom node (ex. $(selector)[0] for jQuery users)
        element: document.getElementById('file-uploader'),
        // path to server-side upload script
        action: '/attachments.js'
    });
  }
});

///////////////////////////////////////////////
//
///////////////////////////////////////////////

//PrivatePub.subscribe("/messages/new", function(data, channel) {
//  $("tr.message:last-child").after(data.chat_message);
//});

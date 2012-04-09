///////////////////////////////////
// Recipient User Selection
///////////////////////////////////

var toggleRecipientSelectionSection = function() {
  recipient_selection_section = $('#recipient_selection_section');
  recipient_selection_section.toggle();

  height = recipient_selection_section.outerHeight(true);
    
  if (recipient_selection_section.is(":hidden")) {
    console.log("hiding: " + height);
    $('#messages_section').css("height", "+=" + height);
  } else {
    console.log("showing: " + height);
    $('#messages_section').css("height", "-=" + height);   
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

  PrivatePub.subscribe("/messages/" + user_name, function(data, channel) {
    // play tone
    $('#tone')[0].innerHTML = "<embed src=/assets/soft_chime_beep.mp3 hidden=true autostart=true loop=false>";

    // clear message text field
    $("input#message_content").val("");

    // create the new message html 
    html ="<li class='message recieved_message'>" +
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
    
    // append the new message html
    $("li.message:last-child").after(html);

    // display/refresh the Recipients and online users
    $.get(
      "/recipients",
      function(response) {
        response;
      }
    );

    // scroll to last message 
    if (data.chat_message) {
      $('#messages_section').scrollTo("max");
    }
  });
});

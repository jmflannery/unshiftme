var build_message = function(sender, attachment_url, content, timestamp, view_class, readers) {
  var html = "<li class='" + view_class + "'>" +
              "<div class='left-side'>" +
                "<div class='sender'>" +
                  "<p>" + sender + "</p>" +
                "</div>" + 
                "<div class='content'>";

                if (attachment_url) {
                  html += "<a href='" + attachment_url + "' target='_blank'>" + content + "</a>";
                } else {
                  html += "<p>" + content + "</p>";
                }
                html += "</div>" +

              "</div>" +
              "<div class='right-side'>" +
                "<div class='timestamp'>" +
                  "<p>" + timestamp + "</p>" +
                "</div>" +
                "<div class='readers'>" +
                  readers +
                "</div>" +
              "</div>" +
            "</li>";
                
  return html;
};

var display_new_message = function(message_html, message_id) {
  message_list_item = $("li.message:first-child");
  var message = $(message_html).data("message_id", message_id).click(read_message);
  if (message_list_item[0]) {
    message_list_item.before(message);
  } else {
    $("ul#message_list").html(message);
  }
};

var display_message = function(message_html, message_id) {
  message_list_item = $("li.message:last-child");
  var message = $(message_html).data("message_id", message_id).click(read_message);
  if (message_list_item[0]) {
    message_list_item.after(message);
  } else {
    $("ul#message_list").html(message);
  }
};


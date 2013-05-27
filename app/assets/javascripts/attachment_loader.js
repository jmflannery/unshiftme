var load_attachments = function() {
  $.getJSON("/attachments", function(data) {
    $.each(data, function(index, value) {
      var li = "";
      li += "<li class='file'>";
      li += "<a href='" + value.payload_url + "' target='_blank'>";
      li += value.payload_identifier;
      li += "</a></li>";
      $('ul#files_list').append(li);
    });
  });
};

$(function() {
  if (on_files_page()) {
    load_attachments();
  }
});

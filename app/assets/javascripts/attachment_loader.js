var AttachmentsLoader = function(username) {
  this.username = username;
};

AttachmentsLoader.prototype = {

  load_attachments: function() {
    $.getJSON("/users/" + this.username + "/attachments", function(data) {
      $.each(data.attachments, function(index, value) {
        var li = "<li class='file'>";
        li += "<a href='" + value.payload_url + "' target='_blank'>";
        li += "<i class='fa fa-file'></i>";
        li += value.payload_identifier;
        li += "</a></li>";
        $('ul#files_list').append(li);
      });
    });
  }
};

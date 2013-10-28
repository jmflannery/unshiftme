HeaderNav = {

  initialize: function(header_tag, current_page) {
    $(header_tag + ' li.active').removeClass('active');

    if (current_page.match(/transcript/)) {
      current_page = 'transcripts';
    } else if (current_page.match(/profile/) || current_page.match(/password/)) {
      current_page = 'profile';
    }

    $(header_tag + ' li#' + current_page + '_button').addClass('active');
  }
};

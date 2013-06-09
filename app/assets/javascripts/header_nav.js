$(function() {
  $('#main_menu li.active').removeClass('active');
  if (on_messaging_page()) {
    $('#main_menu li#messages_button').addClass('active');
  } else if (on_files_page()) {
    $('#main_menu li#files_button').addClass('active');
  } else if (on_profile_page()) {
    $('#main_menu li#profile_button').addClass('active');
  } else if (on_transcript_page() || on_transcripts_page() || on_new_transcript_page()) {
    $('#main_menu li#transcripts_button').addClass('active');
  } else if (on_manage_users_page()) {
    $('#main_menu li#manage_users_button').addClass('active');
  }
});

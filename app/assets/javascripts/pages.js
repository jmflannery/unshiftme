// on messaging page?
var on_messaging_page = function() {
  var on_page = false;
  if ($("#messaging_page").length > 0) {
    on_page = true;
  }
  return on_page;
};

// on edit profile page?
var on_profile_page = function() {
  var on_page = false;
  if ($("#edit_profile_page").length > 0) {
    on_page = true;
  }
  return on_page;
};

// on transcripts page?
var on_transcripts_page = function() {
  var on_page = false;
  if ($("#transcripts_page").length > 0) {
    on_page = true;
  }
  return on_page;
};

// on transcript page?
var on_transcript_page = function() {
  var on_page = false;
  if ($("#transcript_page").length > 0) {
    on_page = true;
  }
  return on_page; 
};

// on files page?
var on_files_page = function() {
  var on_page = false;
  if ($("#files_page").length > 0) {
    on_page = true;
  }
  return on_page; 
};

// on new transcript page?
var on_new_transcript_page = function() {
  var on_page = false;
  if ($("#new_transcript_page").length > 0) {
    on_page = true;
  }
  return on_page; 
};

// on new manage users page?
var on_manage_users_page = function() {
  var on_page = false;
  if ($("#manage_users_page").length > 0) {
    on_page = true;
  }
  return on_page; 
};

// on new manage users page?
var on_files_page = function() {
  var on_page = false;
  if ($("#files_page").length > 0) {
    on_page = true;
  }
  return on_page; 
};

var signed_in = function() {
  var signed_in = false;
  if (on_messaging_page() ||
      on_files_page() ||
      on_profile_page() ||
      on_transcript_page() ||
      on_transcripts_page() ||
      on_new_transcript_page() ||
      on_manage_users_page()) {
    signed_in = true;
  }
  return signed_in;
};

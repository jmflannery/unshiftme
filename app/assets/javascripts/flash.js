var flash = function(message) {
  $('#flash').html(message).delay(200).fadeIn('normal', function() {
    $(this).delay(9000).fadeOut();
  });
};


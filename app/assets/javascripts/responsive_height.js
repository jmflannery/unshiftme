var ResponsiveHeight = function() {};

ResponsiveHeight.prototype = {

  setup: function() {
    this.calculate_message_section_height(); 
    $(window).resize(this.calculate_message_section_height);
  },

  // calculate_message_section_height
  // resize the '#message_list_section' to be 68% of the window
  calculate_message_section_height: function() {
    height = $(window).outerHeight(true);
    outer_height = (height * 80) / 100;
    inner_height = (outer_height * 80) / 100;
    $('#content').height(outer_height);
    $('#message_list_section').height(inner_height);
  }
};

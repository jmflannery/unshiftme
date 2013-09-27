var VolumeSlider = function(slider, button) {
  this.$volume_slider = $(slider);
  this.$volume_button = $(button);
  this.$slider = $("<div id='slider'/>");
  this.$volume_slider.append(this.$slider);
  this.bindEvents();
  this.$volume_slider.hide();
};

VolumeSlider.prototype = {
  setup: function() {
    this.$slider.slider({ animate: "fast", orientation: "vertical" });
  },

  bindEvents: function() {
    this.$volume_button.hover(this.showVolume.bind(this), this.hideVolume.bind(this));
    this.$volume_slider.hover(this.showVolume.bind(this), this.hideVolume.bind(this));
  },

  showVolume: function(e) {
    e.preventDefault();
    this.$volume_button.addClass('active');
    this.setSliderPosition();
    this.$volume_slider.show();
  },

  hideVolume: function(e) {
    e.preventDefault();
    this.$volume_button.removeClass('active');
    this.$volume_slider.hide();
  },

  setSliderPosition: function() {
    this.$volume_slider.css({
      'left': this.leftPosition(),
      'top': this.topPosition(),
    });
  },

  topPosition: function() {
    return this.$volume_button.position().top + this.$volume_button.height() + 10;
  },

  leftPosition: function() {
    return this.$volume_button.position().left;
  }
};

$(function() {
  new VolumeSlider('#volume_slider', '#volume_button').setup();
});


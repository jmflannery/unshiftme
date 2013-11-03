var VolumeSlider = function(slider, button) {
  this.INITIAL_VOLUME = 50;
  this.$volume_slider = $(slider);
  this.$volume_button = $(button);
  this.$tooltip = $("<div id='tooltip'/>");
  this.$tooltip.hide();
  this.$slider = $("<div id='slider'/>");
  this.$volume_slider.append(this.$tooltip, this.$slider);
  this.bindEvents();
  this.$volume_slider.hide();
  this.setVolumeIcon(this.INITIAL_VOLUME);

  this.slider_attrs = {
    animate: "fast",
    orientation: "vertical",
    range: "min",
    value: this.INITIAL_VOLUME,

    start: function(event, ui) {
      var value = this.$slider.slider('value');
      this.$tooltip.css('bottom', value).text(ui.value);
      this.$tooltip.fadeIn('fast');
    }.bind(this),

    slide: function(event, ui) {
      var value = this.$slider.slider('value');
      this.$tooltip.css('bottom', value).text(ui.value);
      this.setVolumeIcon(ui.value);
    }.bind(this),

    stop: function(event, ui) {
      this.$tooltip.fadeOut('fast');
    }.bind(this)
  };
};

VolumeSlider.prototype = {

  setup: function() {
    this.$slider.slider(this.slider_attrs);
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

  setVolumeIcon: function(val) {
    if (val >= 50) {
      this.$volume_button.html("<i class='icon-volume-up'></i>");
    } else if (val >= 1 && val < 50) {
      this.$volume_button.html("<i class='icon-volume-down'></i>");
    } else if (val == 0) {
      this.$volume_button.html("<i class='icon-volume-off'></i>");
    }
  },

  setSliderPosition: function() {
    this.$volume_slider.css({
      'left': this.leftPosition(),
      'top': this.topPosition(),
    });
  },

  topPosition: function() {
    return this.$volume_button.offset().top + this.$volume_button.height() + 16;
  },

  leftPosition: function() {
    return this.$volume_button.offset().left;
  }
};

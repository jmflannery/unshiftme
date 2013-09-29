var Beeper = function(audio, slider) {
  this.audio = $(audio).get(0);
  this.$volume_slider = $(slider);
};

Beeper.prototype = {

  getVolume: function() {
    return parseInt(this.$volume_slider.slider("value")) * 0.01;
  },

  beep: function() {
    this.audio.volume = this.getVolume();
    this.audio.play();
  }
};

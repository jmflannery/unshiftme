// Returns the array of class names
$.fn.getClassNames = function() {
  var klasses = $(this).attr("class");
  if (klasses != null) {
    return klasses.split(" ");
  } else {
    return [];
  }
};

// returns true if the passed in string is a class of $(this)
$.fn.hasClass = function(klas) {
  var has = false;
  var klasses = $(this).getClassNames();
  for (i = 0; i < klasses.length; i += 1) {
    if (klasses[i] == klas) {
      has = i;
      break;
    }
  }
  return has;
};

// returns the first class found that can be parsed to int, or false if none found
$.fn.getNumberClass = function() {
  var num = false;
  var klasses = $(this).getClassNames();
  for (i = 0; i < klasses.length; i += 1) {
    if (!isNaN(klasses[i])) {
      num = klasses[i];
      break;
    }
  }
  return num;
};

// returns "on" if the given element has the class "on"
// returns "off" if the given element has the class "off"
// returns false if class "on" or "off" is not found on given element
// returns fasle if both "on" and "off" are found
$.fn.onOff = function() {
  var on = $(this).hasClass("on");
  var off = $(this).hasClass("off");
  if (on && !off) {
    status = "on";
  } else if (off && !on) {
    status = "off";
  } else {
    status = false;
  }
  return status;
};


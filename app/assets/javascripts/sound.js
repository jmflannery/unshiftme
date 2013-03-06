function beep() {
  try {
    loadAndPlaySound(new webkitAudioContext());
  } catch(e) {
    //onError();
  }
}

function loadAndPlaySound(context) {
  //request.responseType = 'arraybuffer';
  $.get('/assets/soft_chime_beep.mp3', function(response) {
    //console.log(response.inspect());
    context.decodeAudioData(response, function(buffer) {
      console.log("fffi");
     playSound(context, buffer);
    }, onError);
  });
}

function playSound(context, buffer) {
  var source = context.createBufferSource();
  source.buffer = buffer;
  source.connect(context.destination);
  source.noteOn(0);
}

function onError() {
  console.log("An error occurred loading sound file");
}

WorkstationRadioButtons = {

  initialize: function() {
    $("#td_workstations input").click(function() {
      $("#ops_workstations input").removeAttr("checked");
    });
    $("input#YDCTL").click(function() {
      $("#td_workstations input").removeAttr("checked");
      $("input#YDMSTR").removeAttr("checked");
      $("input#GLHSE").removeAttr("checked");
      $("input#CCC").removeAttr("checked");
    });
    $("input#YDMSTR").click(function() {
      $("#td_workstations input").removeAttr("checked");
      $("input#YDCTL").removeAttr("checked");
      $("input#GLHSE").removeAttr("checked");
      $("input#CCC").removeAttr("checked");
    });
    $("input#GLHSE").click(function() {
      $("#td_workstations input").removeAttr("checked");
      $("input#YDCTL").removeAttr("checked");
      $("input#YDMSTR").removeAttr("checked");
      $("input#CCC").removeAttr("checked");
    });
    $("input#CCC").click(function() {
      $("#td_workstations input").removeAttr("checked");
      $("input#YDCTL").removeAttr("checked");
      $("input#YDMSTR").removeAttr("checked");
      $("input#GLHSE").removeAttr("checked");
    });
  }
};

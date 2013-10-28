var WorkstationAutoSelect = {

  setup: function() {
    $("input#user_name").focusout(function(event) {
      name = event.target.value;
      if (name) { 
        // GET - sessions#new
        $.ajax( {
          type: "GET", 
          url: "/session/new.json",
          data: { "user": name },
          success: function(response) {
            if (response.normal_workstations) {
              $("input:checkbox").removeAttr("checked");
              var normal_workstations = response.normal_workstations.split(",");
              var i;
              for (i = 0; i < normal_workstations.length; i++) {
                $("input#" + normal_workstations[i]).prop("checked", true);
              }
            }
          }
        });
      }
    });
  }
};

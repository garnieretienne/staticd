$(document).ready(function(){

  $("#refresh").click(function(){
     location.reload();
  });

  $("#done").click(function(){
    $.ajax({
      url: "/api/v1/welcome",
      type: "DELETE",
    }).done(function(data){
      location.reload();
    });
  });
});

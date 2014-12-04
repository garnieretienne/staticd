$(document).ready(function(){

  $("#refresh").click(function(){
     location.reload();
  });

  $("#done").click(function(){
    $.ajax({
      url: "/api/welcome",
      type: "DELETE",
    }).done(function(data){
      location.reload();
    });
  });
});

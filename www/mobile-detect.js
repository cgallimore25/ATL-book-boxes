$(document).on('shiny:sessioninitialized', function (e) {
  var mobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) 
               || window.innerWidth <= 768;
  console.log("Mobile Detection:", mobile);
  Shiny.onInputChange('is_mobile_device', true);  // Force mobile mode

  // Shiny.onInputChange('is_mobile_device', mobile);
});
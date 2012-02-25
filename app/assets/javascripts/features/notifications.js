APP.features.notifications = {
  init: function () {
    $('#notification-bar').slideDown();

    $('body').click(function() { 
      $('#notification-bar').slideUp();
      $('#warning').fadeOut();
    });
  }
}
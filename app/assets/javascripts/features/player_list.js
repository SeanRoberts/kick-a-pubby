APP.features.playerList = {
  load: function () {
    var self = APP.features.playerList;
    self.$container = $('#player-list');
    $.ajax({
      url: '/players',
      dataType: 'html',
      success: self.show,
      error: self.error
    });
  },

  show: function (data) {
    var self = APP.features.playerList;

    self.$container
      .find('p')
        .hide()
        .end()
      .html(data)
      .find('table')
        .fadeIn('fast');
  },

  error: function () {
    var self = APP.features.playerList;

    self.$container
      .find('p')
        .hide()
        .end()
      .html('Error loading player list.');
  }
};
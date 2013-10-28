$(function() {

  var App = {

    pages: {
      "messaging": /^\/users\/\w+$/,
      "files": /^\/users\/\w+\/attachments$/,
      "edit-profile": /^\/users\/\w+\/edit$/,
      "edit-password": /^\/users\/\w+\/edit_password$/,
      "transcripts": /^\/users\/\w+\/transcripts$/,
      "new-transcript": /^\/users\/\w+\/transcripts\/new$/,
      "transcript": /^\/users\/\w+\/transcripts\/\d+$/,
      "users": /^\/users$/, // BUG: router.currentUser() will be ''
      "register": /^\/register$/,
      "signin": /^\/signin$/,
      "root": /^\/$/
    },

    initialize: function() {
      this.router = new Router(this.pages);
      this.current_page = this.router.currentPage();
      this.current_user = this.router.currentUser();

      switch (this.current_page) {
        case "messaging":
          new ResponsiveHeight().setup();

          new VolumeSlider('#volume_slider', '#volume_button').setup();
          // Beeper depends on VolumeSlider already existing.. TODO: fix that or make more obvious
          this.beeper = new Beeper('audio', '#slider');

          var recipient_dashboard = new RecipientDashboard('#recipient_selection_section', this.current_user);
          recipient_dashboard.build();

          var message_loader = new MessageLoader(this.current_user);
          message_loader.loadMessages();

          var notifier = new Notifier(this.current_user);

          notifier.subscribe('messages', Notifications.messageReceivedHandler.bind(this));
          notifier.subscribe('readers', Notifications.acknowledgementReceivedHandler);
          notifier.subscribe('workstations', Notifications.workstationUserChangedHandler);

          break;
        case 'transcript':

          var transcript_loader = new TranscriptLoader(this.current_user);
          transcript_loader.load_transcript();

          break;
      };
    }
  };

  App.initialize();
});

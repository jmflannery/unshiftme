$(function() {

  var pages = {
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
  };

  var router = new Router(pages),
      page = router.currentPage(),
      username = router.currentUser();

  console.log(page);
  console.log(username);

  switch (page) {
    case "messaging":
      new ResponsiveHeight().setup();

      var recipient_dashboard = new RecipientDashboard('#recipient_selection_section', username);
      recipient_dashboard.build();

      var message_loader = new MessageLoader(username);
      message_loader.loadMessages();

      var receiver = new MessageReceiver(username);
      receiver.subscribe();

      break;
  }
});

$(function() {
  
  var Router = function(pages) {
    this.pages = pages || {};
  };

  Router.prototype = {
    
    registerPage: function(title, pattern) {
      this.pages[title] = pattern;
    },

    currentPage: function() {
      var page = '';
      for (var key in this.pages) {
        if (this.pages[key].test(this.currentPath())) {
          page = key;
          break
        }
      }
      return page;
    },

    currentPath: function() {
      return window.location.pathname;
    }
  };

  var pages = {
    "messaging": /^\/users\/\w+$/,
    "files": /^\/attachments$/,
    "edit-profile": /^\/users\/\w+\/edit$/,
    "edit-password": /^\/users\/\w+\/edit_password$/,
    "transcripts": /^\/transcripts$/,
    "new-transcript": /^\/transcripts\/new$/,
    "transcript": /^\/transcripts\/\d+$/,
    "users": /^\/users$/,
    "register": /^\/register$/,
    "signin": /^\/signin$/,
    "root": /^\/$/
  };

  var router = new Router(pages);
  var page = router.currentPage();
});

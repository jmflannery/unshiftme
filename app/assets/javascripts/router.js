var Router = function(pages) {
  this.pages = pages || {};
  this.user = '';
  this.current_page = null;
  this.current_path = window.location.pathname;
  this.current_user = '';
};

Router.prototype = {
  
  registerPage: function(title, pattern) {
    this.pages[title] = pattern;
  },
  
  currentPage: function() {
    return this.current_page || (this.current_page = this._currentPage());
  },

  _currentPage: function() {
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
    return this.current_path || (this.current_path = window.location.pathname);
  },

  currentUser: function() {
    return this.current_user || (this.current_user = this._currentUser());
  },

  _currentUser: function() {
    var user = '';
    var parts = this.currentPath().split('/');
    if (parts[2]) {
      user = parts[2];
    }
    return user;
  }
};

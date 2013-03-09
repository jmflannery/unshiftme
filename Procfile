web: thin start
faye: rackup private_pub.ru -s thin -E production
log: rm log/development.log && touch log/development.log && tail -f log/development.log
#scheduler: rake rufus:scheduler

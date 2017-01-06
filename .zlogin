test -d /var/login_msg.d && test ! -z `ls /var/login_msg.d` && cat /var/login_msg.d/*
test -d `cat ~/.last_pwd` && cd `cat ~/.last_pwd`

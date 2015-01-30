xymon-php-fpm
=============
xymon-php-fpm is a perl script that you can use to monitor a php-fpm installation and graph its counters into your BB/Hobbit/Xymon server.

![A xymon page featuring some php-fpm counters](https://raw.github.com/ZeWaren/xymon-php-fpm/master/example_graphs/xymon_page.png "A xymon page featuring some php-fpm counters")

How it works
------------

`xymon_php_fpm.pl` connects to your php-fpm server status page to get the needed data.

The values are then posted into the host's trends data channel.

Some HTML code is also posted as a status, in order to be able to see the graphs alone on one page (ugly but works). If you only want the graphs to appear in the trends page, you can remove the line that send the status and then set the `TRENDS` variable in `xymonserver.cfg`.

Installation
------------
+ Copy `xymon_php_fpm.pl` somewhere executable by your xymon client (typically `$HOBBITCLIENTHOME/ext` or `$XYMONCLIENTHOME/ext`). Set the permissions accordingly.

Configure your php-fpm pool to have a status page:
```
pm.status_path = /php-fpm-status
```
 
If you're using nginx, configure it accordingly:

```
    server {
        listen                  10.0.13.11:82 default;
        server_name             _;
        access_log              off;
        error_log               off;
        server_tokens           off;

        location /php-fpm-status {
                fastcgi_pass unix:/var/run/phph-fpm-www.socket;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                include fastcgi_params;
                allow 10.0.0.0/16;
                deny all;
        }
    }
```

+ Edit the script to provide the url to the status page.
```
use constant PHP_FPM_STATUS_PAGE => '"http://10.0.13.11:82/php-fpm-status"';
```

+ Makes xymon execute the script periodically.
In `hobbitlaunch.cfg` (Hobbit)
```
[phpfpm]
    ENVFILE $HOBBITCLIENTHOME/etc/hobbitclient.cfg
    CMD $HOBBITCLIENTHOME/ext/xymon_php_fpm.pl
    LOGFILE $HOBBITCLIENTHOME/logs/hobbit-phpfpm.log
    INTERVAL 3m
```
or in `clientlaunch.cfg` (Xymon)
```
[phpfpm]
    ENVFILE $XYMONCLIENTHOME/etc/xymonclient.cfg
    CMD $XYMONCLIENTHOME/ext/xymon_php_fpm.pl
    LOGFILE $XYMONCLIENTLOGS/xymon-phpfpm.log
    INTERVAL 3m
```

+ Append or include the provided file to `graphs.cfg`.

+ Restart xymon-client.

Sample graphs:
--------------

![PHP-FPM Connections](https://raw.github.com/ZeWaren/xymon-php-fpm/master/example_graphs/phpfpm_connections.png "PHP-FPM Connections")

![PHP-FPM Processes](https://raw.github.com/ZeWaren/xymon-php-fpm/master/example_graphs/phpfpm_processes.png "PHP-FPM Processes")

Credits:
--------

xymon-php-fpm was written in January 2015 by: ZeWaren / Erwan Martin <<public@fzwte.net>>.

It is licensed under the MIT License.

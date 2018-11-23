[supervisord]
nodaemon=true

[program:laravel-horizon]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/application/artisan horizon
autostart=true
autorestart=true
numprocs=1
startretries=10
stdout_events_enabled=1

[program:cron]
command = /usr/sbin/cron -f -L 15
user = root
autostart = true
autorestart = true
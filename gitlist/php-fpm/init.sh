rm -Rf /var/www/html/*
mkdir -p /var/www/html/browse/cache /var/www/html/logs /var/log/nginx/goaccess
cp -r /application/* /var/www/html/browse/

## create symlinks that will be found by the webserver
ln -s /var/git/packages.json /var/www/html/browse/ 
ln -s /var/git/status.log /var/www/html/browse/
ln -s /var/git/commit_counts.json /var/www/html/browse/commit_counts.json
ln -s /var/git/all_commits.rds /var/www/html/browse/all_commits.rds

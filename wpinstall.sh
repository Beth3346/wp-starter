#!/bin/bash -e

clear

composer install

echo "================================================================="
echo "Beth's Awesome WordPress Installer!!"
echo "================================================================="

# accept the name of our website
echo "Site Name: "
read -e sitename

# accept user input for the user name
echo "Username: "
read -e wpuser

# accept user input for the user name
echo "Password: "
read -e wppass

# accept user input for the user email
echo "Admin Email: "
read -e wpemail

# accept user input for the site address
echo "Site Address: "
read -e siteaddress

# accept user input for the database name
# echo "Database Name: "
# read -e dbname

# accept user input for the database user
# echo "Database user: "
# read -e dbuser

# accept user input for the database password
# echo "Database Password: "
# read -e dbpass

# accept a comma separated list of pages
echo "Add Pages: "
read -e allpages

# accept a comma separated list of categories
echo "Add Categories: "
read -e allcategories

# create database, and install WordPress
# wp db create
wp core install --url="$siteaddress/wp" --title="$sitename" --admin_user="$wpuser" --admin_password="$wppass" --admin_email="$wpemail"

# show only 5 posts on an archive page
wp option update posts_per_page 5
wp option update home $siteaddress

# delete sample page, and create homepage
wp post delete $(wp post list --post_type=page --posts_per_page=1 --post_status=publish --pagename="sample-page" --field=ID --format=ids)
wp post delete $(wp post list --post_type=post --posts_per_page=1 --post_status=publish --postname="hello-world" --field=ID --format=ids)
wp post create --post_type=page --post_title=Home --post_status=publish --post_author=$(wp user get $wpuser --field=ID --format=ids)
wp post create --post_type=page --post_title=Blog --post_status=publish --post_author=$(wp user get $wpuser --field=ID --format=ids)

# set homepage as front page
wp option update show_on_front 'page'

# set homepage to be the new page
wp option update page_on_front $(wp post list --post_type=page --post_status=publish --posts_per_page=1 --pagename=home --field=ID --format=ids)
wp option update page_for_posts $(wp post list --post_type=page --post_status=publish --posts_per_page=1 --pagename=blog --field=ID --format=ids)

# set timezone to central
wp option update timezone_string 'America/Chicago'

wp option update blogdescription ''
wp option update default_comment_status 'closed'
wp option update default_ping_status 'closed'
wp option update uploads_use_yearmonth_folders ''

# create all of the pages
export IFS=","
for page in $allpages; do
    wp post create --post_type=page --post_status=publish --post_title="$(echo $page | sed -e 's/^ *//' -e 's/ *$//')"
done

# create all of the categories
export IFS=","
for category in $allcategories; do
    wp term create category $category
done

# set new category to default and remove 'Uncategorized'
wp option update default_category 2
wp option update default_email_category 2
wp term delete category 1

# set pretty urls
wp rewrite structure '/%postname%/' --hard
wp rewrite flush --hard

clear

cd web/app/themes/wp-starter-theme

composer install

cd ../../../../

echo "================================================================="
echo "Installation is complete. Your username/password is listed below."
echo ""
echo "Username: $wpuser"
echo "Password: $wppass"
echo ""
echo "================================================================="

fi
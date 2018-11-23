#!/usr/bin/env bash

# Make sure the user runs this as root
if [ "$(id -u)" -ne 0 ]
then
    echo "You must run this script as root"
    exit 0
fi

rebuild=1
if [ "$1" != 'rebuild' ]
then
    rebuild=0
fi

# make sure we are in the scripts directory no matter what
DIR="$( cd "$( dirname "$0" )" && pwd )"
cd "$DIR" || exit

PHP="/usr/bin/env php"

CHECKOUT_DIR=$(cd .. && pwd && cd scripts || exit)
STORAGE_DIR="$CHECKOUT_DIR/storage"

ENV_FILE="../.env"
ENV_FILE_EXAMPLE="../.env.example"

echo ""
echo -n "Use interactive deploy (RECOMMENDED)? (Y/n)"
read -r inter
if [ "$inter" != 'n' ]
then
    inter="Y"
fi


# function to check whether a mysql installation has a socket or not
# in /tmp/ folder
check_mysql_socket() {
    echo "Checking mysql socket..."
    if [ ! -e /tmp/mysql.sock ]
    then
        echo "Socket does not exists. Linking.."
        if [ -e /var/run/mysqld/mysqld.sock ]
        then
            ln -s /var/run/mysqld/mysqld.sock /tmp/mysql.sock
        else
            echo "Impossible to link the socket! EPIC FAIL"
 #           exit 0
        fi
    fi
}

# function to test option to proceed
# confirm DEFAULT_VALUE MESSAGE
confirm() {
    pass=1
    if [ "$1" != 'n' ]
    then
        echo -n "$2 "
        read -r testt

        if [ "$testt" != 'n' ]
        then
            pass=0
        fi
    else
        pass=0
    fi
    return $pass
}

confirmFalse() {
    pass=1
    if [ "$1" != 'y' ]
    then
        echo -n "$2 "
        read -r testt

        if [ "$testt" != 'y' ]
        then
            pass=0
        fi
    else
        pass=0
    fi
    return $pass
}

runPhpArtisan() {
    $PHP "$DIR"/../artisan "$1"
}


# Update the env file. If the file does not exist, copy it. If it exists, use vimdiff to merge them. If it is not
# available, simply warn the user (in red!)
echo ""
echo "Checking environment files..."
if [ -f $ENV_FILE ]
then
    echo "Configuration file exists ($ENV_FILE)."
    if [ "$(diff $ENV_FILE_EXAMPLE $ENV_FILE | wc -l)" -ne 0 ]
    then
        echo "Found differences."
        if command -v vimdiff &>/dev/null
        then
            echo -n "Edit differences now? (Y/n) "
            read -r option
            if [ "$option" != 'n' ]
            then
                vimdiff $ENV_FILE_EXAMPLE $ENV_FILE
                if [ "$(diff $ENV_FILE_EXAMPLE $ENV_FILE | wc -l)" -ne 0 ]
                then
                    echo "$(tput setaf 1)You can edit these manually later using vimdiff$(tput sgr0)"
                fi
            fi
        else
            echo "$(tput setaf 1)NOTE: You must update $ENV_FILE file manually!$(tput sgr0)"
        fi
    else
        echo "No changes to environment files."
    fi
else
    # test to avoid trouble..
    echo "No environment file found!"

    if confirm $inter "Create file and edit? (Y/n)"
    then
        echo "Creating new environment file..."
        cp -p $ENV_FILE_EXAMPLE $ENV_FILE
        echo "Now you will edit the file. Do NOT forget to setup the database!"
        read -r -p "Hit enter to continue..."
        vim $ENV_FILE
    fi
fi

READ_INI_CMD="$PHP ./parseEnv.php $ENV_FILE"
application_env="$($READ_INI_CMD APP_ENV)"

echo ""
echo "Installing required modules..."
cd "$CHECKOUT_DIR" || exit
if [ "$application_env" = 'local' ]
then
    composer install
else
    composer install --no-dev
fi
cd "$DIR" || exit

# database section
# get username and password for database
db_database="$($READ_INI_CMD DB_DATABASE)"
db_username="$($READ_INI_CMD DB_USERNAME)"
db_password="$($READ_INI_CMD DB_PASSWORD)"
db_host="$($READ_INI_CMD DB_HOST)"
db_port="$($READ_INI_CMD DB_PORT)"

echo ""
if [ "$rebuild" != '0' ]
then
    # we always check if user wants to rebuild the database
if ! confirmFalse $inter "Create|Rebuild database ($db_database)? (y/N)"
then
    if ! confirm $inter "Is the user '$db_username' able to create databases? (Y/n)"
    then
        echo -n "Provide a username: "
        read -r db_username
        echo -n "Provide the password (won't be displayed): "
        set -v off
        read -r db_password
        set -v on
        echo ""
    fi

    export PGPASSWORD=$db_password
    psql_cmd="psql -U $db_username"
    if [ "$db_host" != "" ]
        then
         psql_cmd="$psql_cmd -h $db_host"
    fi
     psql_cmd="$psql_cmd -p $db_port"

    echo "Dropping database..."
    error=$($psql_cmd -d postgres -c "drop database $db_database;")
    case "$error" in
        *ERROR*) echo "$error" ;;
    esac
        echo "Creating database..."
        error=$($psql_cmd -d postgres -c "create database $db_database;")
    case "$error" in
        *ERROR*) echo "$error" ;;
    esac
    unset PGPASSWORD    
fi
else
    echo "If you want to be able to rebuild the database, please run this script with the parameter 'rebuild'"
fi # End if check if parameter rebuild


echo ""
if confirm $inter "Execute database migrations now? (Y/n) "
then
    runPhpArtisan "migrate"
fi

echo ""
if ! confirmFalse $inter "(Re)generate application key? (y/N) "
then
    runPhpArtisan "key:generate"
fi

# Make sure all the folders have the right permissions
echo ""
echo "Setting up folder permissions..."
chown -R www-data:www-data "$STORAGE_DIR/logs"
chown -R www-data:www-data "$STORAGE_DIR/framework"
chown -R www-data:www-data "$STORAGE_DIR/debugbar"

# Make sure the cache folder is empty
echo ""
echo "Removing old files..."
runPhpArtisan "clear-compiled"
runPhpArtisan "config:clear"
runPhpArtisan "route:clear"
runPhpArtisan "view:clear"
runPhpArtisan "cache:clear"

# We don't want to cache stuff in dev since it changes a lot
if [ "$application_env" = 'production' ]
then
    echo ""
    echo "Caching configurations..."
    runPhpArtisan "config:cache"
    runPhpArtisan "route:cache"
fi


# Set up permissions, etc
echo ""
echo "Bootstrapping application..."
runPhpArtisan "db:seed"

echo ""
if confirm $inter "Build assets? (Y/n) "
then
    npm install

    if [ "$application_env" = 'local' ]
    then
        npm run dev
    else
        npm run production
    fi
fi

echo ""
echo "Setup completed!"
echo ""

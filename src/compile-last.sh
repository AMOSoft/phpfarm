#!/bin/bash

FORCE=
VERSION=
VERSION_COMPLETE_REQUESTED=


function usage() {
    cat << EOF
Ce script permet d\'installer la derniere version de php

USAGE: $0 [PHPVERSION]

OPTIONS:
    -h                      Affiche ce message d\'aide
    -f                      Force sans message de confirmation
    -v                      Version php que l\'on souhaite installer
    -s|show                 Affiche uniquement la version qui va être installée.
EOF
}


while getopts ":v:hfs" OPTION
do
    case $OPTION in
        h|help)
            usage
            exit 1
            echo "1"
            ;;
        f)
            FORCE=1
            ;;
        v)
            VERSION=$OPTARG
            ;;
        s|show)
            VERSION_COMPLETE_REQUESTED=1
            ;;
        \?)
            echo -e "\033[31mOption non valide : -${OPTARG}\033[0m\n"
            usage
            exit
            ;;

        :)
            echo -e "\033[31mL'option -${OPTARG} nécessite un argument\033[0m\n"
            usage
            exit
            ;;
     esac
done

if [[ -z "$VERSION" ]]
then
    echo $VERSION;
    usage
    echo -e "\nYou must pass the PHP group version 5.5 / 5.6 / 7.0\n"
    exit 1
fi

prefix="$(echo "$VERSION" | sed 's/\./\\\./')"
version="$(curl -s "https://secure.php.net/releases/" | grep -o -m 1 '"'$prefix'\.[0-9]\+"' | awk -F'"' '{print $2}')"

if [ "$version" == "" ]; then
    echo -e "\nNo version found starting with $1 \n"
    exit 1
fi

if [[ "$VERSION_COMPLETE_REQUESTED" == 1 ]]
then
  echo -e "$version"
  exit 1
fi



if [[ -z "$FORCE" ]]
then
  read -p "Last version from PHP releases website is $version - Install it? [y/n] " response

  if [ "$response" != "y" ]; then
      echo -e "\nCanceled\n"
      exit 1
  fi
fi


if [ ! -f "custom-options-$version.sh" ]; then
    if [[ -z "$FORCE" ]]
    then
      read -p "There aren't a custom-options-$version.sh file. Use default options from custom-options-default.sh? [y/n] " custom
      if [ "$custom" == "y" ]; then
          cp -p "custom-options-default.sh" "custom-options-$version.sh"
      fi
    else
      cp -p "custom-options-default.sh" "custom-options-$version.sh"
    fi
fi

if [ ! -f "default-custom-php.ini" ]; then
    if [ -f /etc/timezone ]; then
        echo 'date.timezone="'$(cat /etc/timezone)'"' >> default-custom-php.ini
    fi

    echo 'include_path=".:/opt/phpfarm/inst/php-'$version'/pear/php/"' >> default-custom-php.ini
fi

./compile.sh $version

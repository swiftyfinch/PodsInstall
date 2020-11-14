#!/usr/bin/bash

# Created by Vyacheslav Khorkov on 23.05.2020.
# Copyright © 2020 Vyacheslav Khorkov. All rights reserved.

function pods_install() {
    red="\001$(tput setaf 1)\002"
    yellow="\001$(tput setaf 3)\002"
    green="\001$(tput setaf 2)\002"
    reset="\001$(tput sgr0)\002"

    if [ "$1" = "-f" ] ; then
        shift 1;
    else
        diff "Podfile.lock" "Pods/Manifest.lock" > /dev/null
        if (( $? == 0 )) ; then
            echo -e "🎉 ${green}Everything is up to date.${reset}"
            return
        fi
    fi

    tries=2
    while (( $tries > 0 ))
    do
        bundle exec pod install "$@"
        error=$?
        if (( error == 7 )) ; then
            echo -e "\n${red}⚠️  Error code: ${error}${reset}"
            echo -e "${yellow}🚑 Let's try bundle install${reset}\n"
            bundle install
        elif (( error == 31 )) ; then
            echo -e "\n${red}⚠️  Error code: ${error}${reset}"
            echo -e "${yellow}🚑 Let's try --repo-update${reset}\n"
            bundle exec pod install --repo-update
        elif (( error != 0 )) ; then
            echo -e "\n${red}⚠️  Error code: ${error}${reset}"
            break
        else
            echo -e "🎉 ${green}Everything fine.${reset}"
            break
        fi

        tries=$(( $tries - 1 ))
    done

    tput bel
    unset red yellow reset tries
}

function pods() {
  case $* in
    install! ) shift 1; pods_install -f "$@" ;;
    install ) shift 1; pods_install "$@" ;;
    * ) command bundle exec pod "$@" ;;
  esac
}

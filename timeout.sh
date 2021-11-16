#!/bin/bash

function usage {
    echo "Add the specified proxy timeout to the Vesta template"
    echo
    echo "Usage: timeout.sh <--help/--list>"
    echo "       timeout.sh <seconds> [template]"
    echo
    echo "--help, -h	Print this help"
    echo "--list, -l	Print avaliable templates"
    echo
    echo "If you don't specify a template name, default template will be selected."
}

function check-number {
    REG='^[0-9]+$'
    if ! [[ $1 =~ $REG ]]
    then
        echo "Error: Agrument is not a number. Use: timeout.sh --help" >&2
        exit -1
    fi
}

function arg-handler {
    if [ -z "$1" ]; then echo "No argument found. Use: timeout.sh --help"; exit 1; fi

    if [ "$1" == "--help" ] || [ "$1" == "-h" ]
    then 
        usage
        exit 0
    fi

    if [ "$1" == "--list" ] || [ "$1" == "-l" ]
    then
        v-list-web-templates-proxy  | sed '1,2d'
        exit 0
    fi

    TIME=$1
    check-number $TIME
   
    if [ -n "$2" ]
    then TEMPLATE=$2   
    else TEMPLATE="default"
    fi

    if ! v-list-web-templates-proxy  | sed '1,2d' | grep $TEMPLATE >/dev/null 2>&1
    then
        echo "Template $TEMPLATE not found. Avaliable templates:"
        v-list-web-templates-proxy  | sed '1,2d'
        exit 1
    fi
}

function create-template {
    local TAB="       "
    local TPL_PATH="/usr/local/vesta/data/templates/web/nginx"

    if [ -f $TPL_PATH/${TEMPLATE}_$TIME.tpl ] || [ -f $TPL_PATH/${TEMPLATE}_$TIME.stpl ]
    then
        echo "Template ${TEMPLATE}_$TIME already exist. Check templates dir - $TPL_PATH/"
        exit 1
    fi

    cp -v $TPL_PATH/$TEMPLATE.tpl $TPL_PATH/${TEMPLATE}_$TIME.tpl
    cp -v $TPL_PATH/$TEMPLATE.stpl $TPL_PATH/${TEMPLATE}_$TIME.stpl

    sed -i "/location \x2f {/ a\\$TAB proxy_connect_timeout $TIME;\n\\$TAB proxy_send_timeout $TIME;\n\\$TAB proxy_read_timeout $TIME;\n\\$TAB send_timeout $TIME;\n" \
    $TPL_PATH/${TEMPLATE}_$TIME.tpl && \
    sed -i "/location \x2f {/ a\\$TAB proxy_connect_timeout $TIME;\n\\$TAB proxy_send_timeout $TIME;\n\\$TAB proxy_read_timeout $TIME;\n\\$TAB send_timeout $TIME;\n" \
    $TPL_PATH/${TEMPLATE}_$TIME.stpl && \
    echo -e "DONE!\n" && \
    echo "To apply template, use:" && \
    echo "    v-change-web-domain-proxy-tpl admin <domain> ${TEMPLATE}_$TIME" && \
    echo
}

arg-handler "$@"
create-template

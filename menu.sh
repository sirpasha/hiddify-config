#!/bin/bash
cd $( dirname -- "$0"; )
HEIGHT=20
WIDTH=60
CHOICE_HEIGHT=4
BACKTITLE="Welcome to Hiddify Panel (config version=$(cat VERSION))"
TITLE="Hiddify Panel"
MENU="Choose one of the following options:"

OPTIONS=(status "View status of system"
         restart "Restart Services without changing the configs"
         log "view system logs"
         apply_configs "Apply the changed configs"
         update "Update "
         admin "Show admin link"
         install "Reinstall"
         disable "Disable showing this window on startup"
         enable "enable showing this window on startup"
         uninstall "Uninstall"
         )

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
echo "Hiddify: Command $CHOICE"
echo "=========================================="
NEED_KEY=1
case $CHOICE in 
    "") exit;;
    'log')
        W=() # define working array
        while read -r line; do # process file by file
            size=$(ls -lah log/system/$line | awk -F " " {'print $5'})
            W+=($line "$size")
        done < <( ls -1 log/system )
        LOG=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${W[@]}" \
                2>&1 >/dev/tty)
        clear
        echo -e "\033[0m"
        if [[ $LOG != "" ]];then    
            less +G "log/system/$LOG"
        fi
        NEED_KEY=0
    ;;
    "enable")
        echo "/opt/hiddify-config/menu.sh">>~/.bashrc
        echo "cd /opt/hiddify-config/">>~/.bashrc
        NEED_KEY=0
        ;;
    "disable")
        sed -i "s|/opt/hiddify-config/menu.sh||g" ~/.bashrc
        sed -i "s|cd /opt/hiddify-config/||g" ~/.bashrc
        NEED_KEY=0
        ;;
    "admin")
        (cd hiddify-panel; python3 -m hiddifypanel admin-links)   
        ;;
    "status")
        bash status.sh |less +G
        NEED_KEY=0
        ;;
    *)
        bash $CHOICE.sh
esac

if [[ $NEED_KEY == 1 ]];then
    read -p "Press any key to return to menu" -n 1 key

    # if [[ $key == 'q' ]];then
    #     echo ""
    #     exit; 
    # fi
fi
./menu.sh
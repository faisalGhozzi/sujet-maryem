#!/bin/bash
show_usage()
{
 printf "$0: [-h] [-m] [-g] [-c] [-l] [-a] [-b] chemin.." 1>&2; exit 1;
}

help()
{
    cat help.txt
}

service()
{
    sudo grep -n "Starting" /var/log/boot.log
}

mail()
{
    sudo head -n 1 /var/log/maillog
}

connexion()
{
    sudo grep -n "$1" /var/log/secure > "$1.txt" 2>&1
}

alert()
{
    if [ sudo grep -wc "authentication failure.*$1" /var/log/secure -gt 2 ]
    then
        echo "$1 has too many wrong connexions"
    else
	    echo "nothing to report"
    fi
}

graphique()
{
    
    HEIGHT=15
    WIDTH=125
    CHOICE_HEIGHT=4
    TITLE="Scripting proj"
    MENU="Veulliez choisir une option:"

    OPTIONS=(1 "Afficher tentatives de connexion par utilisateur"
            2 "Afficher infraction utilisateur"
            3 "Afficher dernier access mail"
            4 "Afficher services entrain de demarrer"
            )

    exec 3>&1

    CHOICE=$(dialog --clear \
                    --title "$TITLE" \
                    --menu "$MENU" \
                    $HEIGHT $WIDTH $CHOICE_HEIGHT \
                    "${OPTIONS[@]}" \
                    2>&1 1>&3)

    clear
    case $CHOICE in
            1)
                f=$(dialog --clear \
                --title "nombre connexion" \
                --inputbox "Entrer le nom d utilisateur :" 8 40 \
                2>&1 1>&3)

                connexion $f

                dialog --clear \
                --title "nombre connexions $f" \
                --textbox "$f.txt" 8 40

                if [[ $? -eq $DIALOG_OK ]]; then
                graphique
                fi
                ;;
            2)  
                user=$(dialog --clear \
                --title "tentatives erronées" \
                --inputbox "Entrer le nom d utilisateur :" 8 40 \
                2>&1 1>&3)

                msg=$(alert $user)

                dialog --clear \
                --title "nombre connexions erronées $user" \
                --msgbox "$msg" 8 40

                if [[ $? -eq $DIALOG_OK ]]; then
                graphique
                fi
                ;;
            3)
                ml=$(mail)

                dialog --clear \
                --title "Mail log" \
                --msgbox "$ml" 8 40

                if [[ $? -eq $DIALOG_OK ]]; then
                graphique
                fi
                ;;
            4)
                srv=$(service)

                dialog --clear \
                --title "Starting services" \
                --msgbox "$srv" 8 40

                if [[ $? -eq $DIALOG_OK ]]; then
                graphique
                fi
            ;;
    esac
}

menu()
{
    while :
    do
	echo " "
	echo "-------------------------------------"
	echo "            Main Menu "
	echo "-------------------------------------"
	echo "[1] Afficher tentatives de connexion par utilisateur"
	echo "[2] Afficher infraction utilisateur"
	echo "[3] Afficher dernier access mail"
    echo "[4] Afficher services entrain de demarrer"
	echo "[5] Exit"
	echo "====================================="
	echo "Entrez votre choix : [1-5]: "
	read m_menu
	
	case "$m_menu" in

		1) echo "Donner le nom de l utilisateur"; read n; connexion $n ;;
		2) echo "Donner le nom de l utilisateur"; read n; alert $n ;;
        	3) mail ;;
		4) service ;;
        	5) exit 0;;
		*) echo "Choix invalide";
		   echo "Tappez ENTER pour continuer..." ; read ;;
	esac
done
}


main()
{
if [ $# -eq 0 ] 
then
    show_usage
    exit 1
else
    while getopts "hmgc:la:b" opt ; do

    case "${opt}" in
    m)
    menu
    ;;
    h)
    help
    exit 1;
    ;;

    b)
    service
    exit 1;
    ;;

    l)
    mail
    exit 1;
    ;;

    c)
    connexion ${OPTARG}
    exit 1;
    ;;
  
    a)
    alert ${OPTARG}
    exit 1;
    ;;

    g)
    graphique
    ;;
    esac
    done
fi
}

main $*

#!/bin/sh
# Make lancher - Script to create a .desktop launcher at your Gnome desktop
# By Terje Tollefsen

makelancher() {
        lname=`gdialog --inputbox "Lancher $arg name" 200 100 "$arg" 2>&1`
        
        if [ $? -eq 1 ]; then
                exit
        fi

        lcomment=`gdialog --inputbox "Lancher $arg comment" 200 100 "$arg" 2>&1`

        if [ $? -eq 1 ]; then
                exit
        fi

        licon=`gdialog --inputbox "Lancher $arg icon" 200 100 "gnome-ccdesktop.png" 2>&1`

        if [ $? -eq 1 ]; then
                exit
        fi
        
        echo [Desktop Entry] > ~/.gnome-desktop/"$arg.desktop"
        echo Name=$lname >> ~/.gnome-desktop/"$arg.desktop"
        echo Comment=$lcomment >> ~/.gnome-desktop/"$arg.desktop"
        echo Exec=$PWD/$lexec >> ~/.gnome-desktop/"$arg.desktop"
        echo Icon=$licon >> ~/.gnome-desktop/"$arg.desktop"
        echo Terminal=0 >> ~/.gnome-desktop/"$arg.desktop"
        echo Type=Application >> ~/.gnome-desktop/"$arg.desktop"
}

for arg
do

        lexec=$arg

        if [ -f ~/.gnome-desktop/"$arg.desktop" ]; 
        then
                if gdialog --title "Overwrite?" --defaultno --yesno "Launcher $arg already exist. Overwrite?" 200 100
                then            
                        makelancher
                else
                        arg=`gdialog --inputbox ".desktop filename for $arg" 200 100 "New-$arg" 2>&1`
                        
                        if [ $? -eq 1 ]; then
                                exit
                        fi
        
                        makelancher
                fi
        else
                makelancher
        fi
done

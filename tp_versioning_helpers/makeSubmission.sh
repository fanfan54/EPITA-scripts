#!/bin/bash
# Copies the project in the ./workdir folder into a new submission (which follows given ACDC's rules) and pushes it to GitHub.
# Author: fanfan54
# Ver. 5.0 (runs from 0_SCRIPTS)

# Configuration (PLEASE ADAPT YOURS TO YOUR CONFIG!)
# login=`whoami`
login="francois.lefevre"

projects_folder="/home/francois.lefevre/afs/S2/prog_tp"

while [ -z $correct ] || [ $correct != "y" ]
    do

    echo "**********"
    echo "Hello, $login! Let's prepare your submission."
    echo "(makeSubmission release 5.0 for linux and wsl)"
    echo "GITHUB SUPPORT: Enabled"
    echo "MULTI-PROG LANGUAGE SUPPORT: Disabled"
    echo "PROG LANGUAGE SUPPORTED: C#"
    echo "DELETION LIST: Enabled (gitignore tpcs 1.6)"
    echo ""
    echo "CONFIGURATION (edit makeSubmission.sh to modify):"
    echo "login: $login"
    echo ""

    read -p "Input the LoWeRcase short TP ID (will be used in the zip file name to make it like this: rendu-xx-$login.zip): " tp_id
    
    read -p "Input the LoWeRcase TP folder name (given in the title of the ACDC's subject and in the PDF's name, like tpcsx): " tp_folder

    echo ""
    cd $projects_folder/$tp_folder
    echo "Now running in the folder `pwd`, which contains:"
    ls
    echo "And its workdir contains:"
    ls workdir
    echo ""

    read -p "If you want to keep an history of submissions, please input a submission revision id: " rev

    read -p "Do you want to commit and push the new submission to GitHub? (y/N) " use_git
    
    if [ "$rev" = "" ] && [ "$use_git" = "y" ]; then
        keep="N"
        echo "You chose not to keep the submission."
        echo "RECAP: I will export your submission to `pwd`/rendu-$tp_id-$login.zip and I will not backup the file. Then I will commit and push to the GitHub repo."
    elif [ "$rev" = "" ]; then
        keep="N"
        echo "You chose not to keep the submission."
        echo "You chose not to commit and push the new submission to its GitHub repo."
        echo "RECAP: I will export your submission to `pwd`/rendu-$tp_id-$login.zip and I will not backup the file."
    elif [ "$use_git" = "y" ]; then
        keep="y"
        echo "RECAP: I will export your submission to `pwd`/rendu-$tp_id-$login.zip and then I will backup the file to `pwd`/rendu-$rev.zip. Then I will commit and push to the GitHub repo."
    else
        keep="y"
        echo "You chose not to commit and push the new submission to its GitHub repo."
        echo "RECAP: I will export your submission to `pwd`/rendu-$tp_id-$login.zip and then I will backup the file to `pwd`/rendu-$rev.zip"
    fi

    read -p 'Is that correct? (y/N) ' correct
done

echo "Cleaning previous submission...     /----------"
rm -rf /tmp/mks.tmp
rm -rf /tmp/rendu-*
rm -f rendu-$tp_id-$login.zip
mkdir /tmp/mks.tmp
mkdir /tmp/mks.tmp/$login

echo "Copying project...                  //---------"
cp -r workdir/* /tmp/mks.tmp/$login/

echo "Cleaning unnecessary files...       ///--------"
cd /tmp/mks.tmp/$login/

# BELOW: rules hardcoded from EPITAtemplate-tpcs/.gitignore

# Enabling support for globstar in bash
shopt -s globstar

# Visual Studio and JetBrains Rider configs
rm -r -- **/.idea/
rm -r -- **/.vs/
rm -- **/*.DotSettings
rm -- **/*.csproj.user

# Compiled files
rm -r -- **/bin/
rm -r -- **/obj/

# Tests for the program
rm -r -- **/tests/

# Reference files
rm -r -- **/Reference/

# macOS Finder temp files
rm -r -- **/*.DS_Store/
rm -r -- **/__MACOSX/

# Windows Explorer temp files
rm -- **/Thumbs.db

echo "Rewriting AUTHORS, just in case...  ////-------"
echo "* $login" > /tmp/mks.tmp/$login/AUTHORS

echo "Zipping...                          /////------"
cd /tmp/mks.tmp
zip -r /tmp/rendu-$tp_id-$login.zip *

cd $projects_folder/$tp_folder
cp /tmp/rendu-$tp_id-$login.zip rendu-$tp_id-$login.zip

if [ "$keep" = "y" ]; then
    echo "Backing up the submission...        //////-----"
    cp /tmp/rendu-$tp_id-$login.zip rendu-$rev.zip
fi

if [ "$use_git" = "y" ]; then
    echo "Adding files to git...              ///////----"
    git add *
    echo "Committing changes to git...        ////////---"
    git commit -m "(auto) makeSubmission: submission \"$rev\""
    echo "Pushing the submission to GitHub... /////////--"
    git push origin master
fi

echo "Cleaning temporary files.. .        //////////-"
rm -rf /tmp/mks.tmp
rm -rf /tmp/rendu-*

echo "DONE                                ///////////"

exit 0

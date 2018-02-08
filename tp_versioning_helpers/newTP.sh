#!/bin/bash
# Creates a new TP folder, and creates a GitHub repo for it.
# Author: fanfan54
# Ver. 2.1 (runs from 0_SCRIPTS)

# Configuration (PLEASE ADAPT YOURS TO YOUR CONFIG!)
# login=`whoami`
login="francois.lefevre"
github_username="fanfan54"

templates_folder="/home/francois.lefevre/afs/templates"
current_template="tpcs"
projects_folder="/home/francois.lefevre/afs/S2/prog_tp"
downloads_folder="/home/francois.lefevre/Downloads"

while [ -z $correct ] || [ $correct != "y" ]
    do

    echo "**********"
    echo "Hello, $login! Let's create a new TP."
    echo "(newTP release 2.1 for linux and wsl)"
    echo "GITHUB SUPPORT: Enabled"
    echo "MULTI-PROG LANGUAGE SUPPORT: Disabled"
    echo "PROG LANGUAGE SUPPORTED: C#"
    echo ""
    echo "CONFIGURATION (edit newTP.sh to modify):"
    echo "login: $login"
    echo "GitHub username: $github_username"
    echo "Templates folder: $templates_folder"
    echo "Downloads folder: $downloads_folder"
    echo ""

    read -p "Input the LoWeRcase TP folder name (given in the title of the ACDC's subject and in the PDF's name, like tpcsx): " tp_folder
    
    read -p "Input the LoWeRcase target semester (S1 to S10): " semester

    echo ""
    cd $projects_folder
    echo "Now running in the folder `pwd`, which contains:"
    ls
    echo ""

    read -p "Which language do you want to use for the TP subject PDF? (fr, en or nothing to skip saving it): " subject_lang
    
    if [ "$subject_lang" != "fr" ] && [ "$subject_lang" != "en" ]; then
        subject_lang="no"
        echo "You chose not to download the TP subject PDF."
        echo "RECAP: I will create a new folder called `pwd`/$tp_folder, I won't download the subject PDF, I will use the GitHub template EPITAtemplate-tpcs and then push to the GitHub repository EPITA-${semester^^}-TP-$tp_folder. IT HAS TO EXIST, otherwise it won't work."
    else
        echo "RECAP: I will create a new folder called `pwd`/$tp_folder, put the subject PDF in it, use the GitHub template EPITAtemplate-tpcs and then push to the GitHub repository EPITA-${semester^^}-TP-$tp_folder. IT HAS TO EXIST, otherwise it won't work."
    fi

    read -p 'Is that correct? (y/N) ' correct
done

echo "Making the folder...                /------"
git clone git@github.com:$github_username/EPITA-${semester^^}-TP-$tp_folder.git $tp_folder

echo "Refreshing the GitHub template...   //-----"
cd $templates_folder/$current_template
git pull

echo "Copying & adapting the template...  ///----"
cp .gitignore $projects_folder/$tp_folder/.gitignore
rm -rf /tmp/wasgit
mv .git /tmp/wasgit
cp -rf * $projects_folder/$tp_folder/
mv /tmp/wasgit .git

cd $projects_folder/$tp_folder/
echo "# EPITA-${semester^^}-TP-$tp_folder" > README.md

echo "Committing to git...                ////---"
git init
git add *
git add .gitignore
git commit -m "(auto) newTP: Initial commit, cloned from template tpcs"

if [ "$subject_lang" != "no" ]; then
    echo "Adding the TP subject PDF...      /////--"
    echo "=> Waiting for the file... Download and save the subject in $downloads_folder"
        
    while [ ! -f $downloads_folder/*.pdf ]; do
        sleep 1
    done
    
    echo "=> Found a subject PDF, adding it to the project..."
    # Quick fix for bug #3 on GitHub issues
    sleep 5    
    cp $downloads_folder/*.pdf subject_$subject_lang.pdf
    echo "=> Deleting the pdf from Downloads..."
    rm $downloads_folder/*.pdf
    echo "=> Committing to git..."
    git add subject_$subject_lang.pdf
    git commit -m "(auto) newTP: Added subject's PDF for language $subject_lang"
fi

echo "Pushing to GitHub...                //////-"
git push

echo "DONE                                ///////"

exit 0

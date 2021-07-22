#!/bin/bash

#The root path to the folder which you would like to copy
sourceDir="/home/example/public_html/"
#The directory where files will be copied to, this is set to the directory where this script is located
destinationDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/"

#Database Details
sourceDatabase="example"
sourceUsername="dbuser"
sourcePassword="dbpass"
sourceHost="localhost" #Use localhost not 127.0.0.1
sourcePort="3310"

destinationDatabase="example2"
destinationUsername="dbuser"
destinationPassword="dbpass"
destinationHost="localhost" #Use localhost not 127.0.0.1
destinationPort="3310"

#Add any custom queries to run on the destination database after copying. Separated with a ;. Escape backticks \`
#This is useful if you need to update information such as siteurl and home for Wordpress where the path has likely changed
customSQL=""

#Exclude files and directories from being deleted in the destination directory
##Directories
excludeDirs=(
    #"testdir"
)
##Files
excludeFiles=(
    #"testfile.txt"
)

#Exlude files and directories from being copied to the destination directory
excludeRsync=(
    #--exclude='ignoreme.txt'
    #--exclude='ignoremedir'
)

#Do not change these variables!
outputFilename="lts-output.txt"
outputFile=$(echo "${destinationDir}${outputFilename}" | tr -d "\r")
GREEN="\033[0;32m"
CYAN="\033[0;36m"
RED="\033[0;31m"
NC="\033[0m"

#Create a blank output file
rm -f $outputFile
touch $outputFile
chmod 777 $outputFile

echo "<h2>Starting replication of" $sourceDir "to" $destinationDir", this may take some time</h2><br><br>" > $outputFile
printf "Starting replication of ${RED}${sourceDir}${NC} to ${RED}${destinationDir}${NC}, this may take some time\n\n"

#Delete files from destination, ignore lts files and any exclusions (SOON)
echo "Deleting files from destination directory:" $destinationDir >> $outputFile
printf "Deleting files from destination directory: ${RED}${destinationDir}${NC}"

##Directories
find $destinationDir -mindepth 1 -not \( -path "*${excludeDirs[0]}" $(printf -- '-o -path "*%s" ' "${excludeDirs[@]:1}") \) -type d ! -name "lts.sh" -a ! -name "${outputFilename}" -a ! -name "lts-copy.php" -a ! -name "lts-php.php" -a ! -name "lts-test.sh" -exec rm -rf {} \;
##Files
find $destinationDir -mindepth 1 -not \( -path "*${excludeFiles[0]}" $(printf -- '-o -path "*%s" ' "${excludeFiles[@]:1}") \) -type f ! -name "lts.sh" -a ! -name "${outputFilename}" -a ! -name "lts-copy.php" -a ! -name "lts-php.php" -a ! -name "lts-test.sh" -exec rm {} \;

echo "<strong>...Complete</strong><br>" >> $outputFile
printf "${GREEN}...Complete${NC}\n"

#Wipe destination database
echo "Wiping destination database and creating one if none exists:" $destinationDatabase >> $outputFile
printf "Wiping destination database and creating one if none exists: ${RED}${destinationDatabase}${NC}"

mysql -u $destinationUsername -p$destinationPassword -h $destinationHost -P $destinationPort -e "DROP DATABASE IF EXISTS ${destinationDatabase}; CREATE DATABASE IF NOT EXISTS ${destinationDatabase};"

echo "<strong>...Complete</strong><br>" >> $outputFile
printf "${GREEN}...Complete${NC}\n"

#Copy Files
echo "Copying files from source directory:" $sourceDir >> $outputFile
printf "Copying files from source directory: ${RED}${sourceDir}${NC}"

rsync -a "${excludeRsync[@]}" $sourceDir $destinationDir

echo "<strong>...Complete</strong><br>" >> $outputFile
printf "${GREEN}...Complete${NC}\n"

#Copy source database
echo "Copying source database:" $sourceDatabase >> $outputFile
printf "Copying source database: ${RED}${sourceDatabase}${NC}"

mysqldump -P $sourcePort -h $sourceHost -u $sourceUsername -p$sourcePassword $sourceDatabase >> "${destinationDir}source_database.sql"
mysql -P $destinationPort -h $destinationHost -u $destinationUsername -p$destinationPassword $destinationDatabase < "${destinationDir}source_database.sql"

rm -f "${destinationDir}source_database.sql"

echo "<strong>...Complete</strong><br>" >> $outputFile
printf "${GREEN}...Complete${NC}\n"

#Run custom SQL queries
if [ -z "${customSQL}" ]; then
    echo "Running custom SQL queries" >> $outputFile
    printf "Running custom SQL queries"
    
    mysql -P $destinationPort -h $destinationHost -u $destinationUsername -p$destinationPassword $destinationDatabase -e "${customSQL}"
    
    echo "<strong>...Complete</strong><br><br>" >> $outputFile
    printf "${GREEN}...Complete${NC}"
fi

echo "<br><br><h1>Replication has completed successfully. You can now <a href="./">return to the website</a></h1>" >> $outputFile
printf "\n\n${CYAN}Replication has completed successfully${NC}\n"

#Wipe the output file
sleep 10
rm -f $outputFile
touch $outputFile
chmod 777 $outputFile
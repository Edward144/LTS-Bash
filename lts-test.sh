#!/bin/bash

#The root path to the folder which you would like to copy
sourceDir="/var/www/html/_projects/ltssource/"
#The directory where files will be copied to, this is set to the directory where this script is located
destinationDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/"

#Database Details
sourceDatabase="example"
sourceUsername="dbuser"
sourcePassword="dbpassword"
sourceHost="localhost" #Use localhost not 127.0.0.1
sourcePort="3310"

destinationDatabase="example2"
destinationUsername="dbuser"
destinationPassword="dbpassword"
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

printf "Starting replication of ${RED}${sourceDir}${NC} to ${RED}${destinationDir}${NC}, this may take some time\n\n"

#Delete files from destination, ignore lts files and any exclusions (SOON)
printf "Deleting files from destination directory: ${RED}${destinationDir}${NC}"

##Directories
find $destinationDir -mindepth 1 -not \( -path "*${excludeDirs[0]}" $(printf -- '-o -path "*%s" ' "${excludeDirs[@]:1}") \) -type d ! -name "lts.sh" -a ! -name "${outputFilename}" -a ! -name "lts-copy.php" -a ! -name "lts-php.php" -a ! -name "lts-test.sh" -printf "%p\n" -exec basename {} \;
##Files
find $destinationDir -mindepth 1 -not \( -path "*${excludeFiles[0]}" $(printf -- '-o -path "*%s" ' "${excludeFiles[@]:1}") \) -type f ! -name "lts.sh" -a ! -name "${outputFilename}" -a ! -name "lts-copy.php" -a ! -name "lts-php.php" -a ! -name "lts-test.sh" -exec basename {} \;

printf "${GREEN}...Complete${NC}\n"

#Wipe destination database
printf "Checking connection to destination database: ${RED}${destinationDatabase}${NC}\n"

mysql -u $destinationUsername -p$destinationPassword -h $destinationHost -P $destinationPort -e "SELECT 'Connected' AS Status LIMIT 1;"

printf "${GREEN}...Complete${NC}\n"

#Copy Files
printf "Copying files from source directory: ${RED}${sourceDir}${NC}\n"

rsync -a --dry-run --list-only "${excludeRsync[@]}" $sourceDir $destinationDir

printf "${GREEN}...Complete${NC}\n"

#Copy source database
printf "Checking connection to source database: ${RED}${sourceDatabase}${NC}\n"

mysql -P $destinationPort -h $destinationHost -u $destinationUsername -p$destinationPassword $destinationDatabase -e "SELECT 'Connected' AS Status LIMIT 1;"

rm -f "${destinationDir}source_database.sql"

printf "${GREEN}...Complete${NC}\n"

#Run custom SQL queries
if [ ! -z "${customSQL}" ]; then
    printf "Running custom SQL queries"
    
    mysql -P $destinationPort -h $destinationHost -u $destinationUsername -p$destinationPassword $destinationDatabase -e "${customSQL}"
    
    printf "${GREEN}...Complete${NC}"
fi

printf "\n\n${CYAN}Replication has completed successfully${NC}\n"

#Wipe the output file
sleep 10
rm -f $outputFile
touch $outputFile
chmod 777 $outputFile
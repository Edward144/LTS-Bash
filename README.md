# LTS-Bash
 A bash script that can be run from shell or browser to copy a website to a second location.
 
 The name lts comes from it's original purpose "Live to Sandbox", replicating a live website to a development location.
 
## What is it for?
 I created this script initially for a client who wanted a copy of their website for testing changes and updates, without affecting their live site. 
 
 This script will copy all files in a given directory to another, and also copy a MySQL database to another creating the database if it doesn't already exist. The destination database will be dropped and recreated so do not use an existing one expecting data to be appended.
 
## Storing the script
 You should keep all of the script files in the root of the directory where you wish data to be copied to.
 *lts.sh
 *lts-test.sh
 *lts-copy.php
 *lts-php.php
 
## Setting variables
 Within lts.sh are variables for the source directory, desination directory, source database, destination database, and database connection details.
 *sourceDir - The absolute path to the directory you wish to copy
 *destinationDir - The absolute path to the directory you wish to copy to (This can be ignored as it defaults to the same directory as lts.sh)
 *Database connection details
    *sourceDatabase - The name of the source database
    *sourceUsername - The username which will connect to the database
    *sourcePassword - The password for the user which will connect to the database
    *sourceHost - The hostname for the database (use localhost not 127.0.0.1)
    *destinationDatabase - As above but for the destination database
    *destinationUsername - As above but for the destination database
    *destinationPassword - As above but for the destination database
    *detinationHost - As above but for the destination database
 *customSQL - Any custom queries to run on the destination database after the source finishes copying (Make sure to escape special characters)
 *excludeDirs - An array of directories NOT to be deleted from the destination directory
 *excludeFiles - An array of files NOT to be deleted from the destination directory
 *excludeRsync - An array of files and directories NOT to be copied from the source to destination
 
## Running the script
 You can run the script via shell by using bash /path/to/lts.sh
 
 You can run the script via browser by using lts-copy.php, this script uses AJAX to repeatedly pull in lts-output.txt and display the contents on the webpage. You should make sure that the permissions for lts-output.txt are sufficient for the user/group to access the file. There shouldn't be any problem setting permissions to 777 as the content of the file are wiped at the beginning and end of the process.
 
 lts-output.txt is automatically created with 777 permissions and wiped once the script finishes running, so you shouldn't need to worry about creating it or setting permissions.

## Remote hosts
 Currently it is possible to set the hostname for databases to access remote locations, however it is not yet possible to set a remote host for copying files. I am planning on adding this, and in the meantime it shouldn't be difficult to modify the script to allow for it.
 
 I am not planning on allowing a remote destination directory. As the script is designed to be stored within the destination directory, so you should have local access to it anyway.

## lts-test
 The lts-test.sh script is an exact copy of the main lts.sh script. The only difference currently is that it will not copy any files from the source to destination directory.
 
 !!It is planned to have it also list only files to be deleted from the destination directory and test that each database can be connected to successfully without actually dropping or dumping any data.!!
 
 This script should be used to test the results of copying before running the live version of the script. It should only be run from a shell session not a browser.
 
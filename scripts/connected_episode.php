#!/usr/bin/php
<?php
/*
* Examples below
* Note: folder in '' to support whitespaces in folder names
* ./playlist_recursive_by_folder.php folder="ZZZ-SubMaster"
* ./playlist_recursive_by_folder.php folder="ZZZ-SubMaster" list=recursive
* ./playlist_recursive_by_folder.php folder="ZZZ SubMaster Whitespaces" list=recursive
* ./playlist_recursive_by_folder.php folder="ZZZ-SubMaster/fff-threeSubs" list=recursive
*
* ./rfid_trigger_play.sh -d="ZZZ-SubMaster" -v=recursive
* ./rfid_trigger_play.sh -d="ZZZ-SubMaster/fff-threeSubs" -v=recursive
* ./rfid_trigger_play.sh -d="ZZZ SubMaster Whitespaces" -v=recursive
*/

/*
* debug? Conf file line:
* DEBUG_playlist_recursive_by_folder_php="TRUE"
echo getcwd();
$debugLoggingConf = parse_ini_file(getcwd()."/../settings/debugLogging.conf");
if($debugLoggingConf['DEBUG_playlist_recursive_by_folder_php'] == "TRUE") {
    file_put_contents(getcwd()."../logs/debug.log", "\n# DEBUG_playlist_recursive_by_folder_php # " . __FILE__ , FILE_APPEND | LOCK_EX);
    file_put_contents(getcwd()."/../logs/debug.log", "\n  # \$_SERVER['REQUEST_METHOD']: " . $_SERVER['REQUEST_METHOD'] , FILE_APPEND | LOCK_EX);
}
*/
declare(strict_types=1);
$debug = true;

// includes
include_once(__DIR__.'/../htdocs/func.php');
include_once(__DIR__.'/../htdocs/inc.loadClassesByName.php');

// read settings
$settings = new Settings();

/*
* Get params from command line
*/
$params = getopt("", array("folder:", "direction:"));
$folderName = $params['folder'];
$direction = $params['direction'];
if($direction !== 'previous') {
    $direction = 'next';
}

$epCon = EpisodeConnection::fromFolderName($settings, $folderName);
die();

/*
* Create path to folder we want to get a list from
*/
$Actual_Audio_Folder_Path = $Audio_Folders_Path."/".$_GET['folder'];


if(file_exists($Actual_Audio_Folder_Path)) {
    /*
    * now we look recursively only if list=recursive was given when calling this script
    */

    if(isset($_GET['direction']) && $_GET['direction'] == "previous") {
        $confFile = $Actual_Audio_Folder_Path . "/previous.conf";
    } else {
        $confFile = $Actual_Audio_Folder_Path . "/next.conf";
    }

} else {
    fail (255, "\$Actual_Audio_Folder_Path '".$Actual_Audio_Folder_Path."' does not exist\n");
}

// some debugging info
if($debug == "true") {
    print "\$_GET:";
    print_r($_GET);
    print "\$Audio_Folders_Path: ".$Audio_Folders_Path."\n";
    print "\$Audio_Folders_Path_Playlist: ".$Audio_Folders_Path_Playlist."\n";
    print "\$folders:";
    print_r($folders);
}
print $return;

?>

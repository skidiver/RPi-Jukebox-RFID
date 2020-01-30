#!/usr/bin/php
<?php
/*
* Examples below
* Note: folder in '' to support whitespaces in folder names
* ./get_connected_folder.php --folder="ZZZ-SubMaster" --direction="next"
* ./get_connected_folder.php --folder="ZZZ-SubMaster" --direction="previous"
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
$debug = false;

// includes
include_once(__DIR__.'/../htdocs/func.php');
include_once(__DIR__.'/../htdocs/inc.loadClassesByName.php');

// read settings
$settings = new Settings();

/*
* Get params from command line
*/
$params = getopt("", array("folder:", "direction::"));
if (!array_key_exists('folder', $params)) {
    printUsage("Parameter 'folder' is missing!");
}

$folderName = $params['folder'];

if (array_key_exists('direction', $params)) {
    $direction = $params['direction'];
} else {
    $direction = 'next'; // next is default
}

$epCon = EpisodeConnection::fromFolderName($settings, $folderName);
if($direction !== 'previous') { // next is default
    $connection = $epCon->getNext();
} else {
    $connection = $epCon->getPrevious();
}

if (!isset($connection)) {
    exit(1);
}

print($connection->getPathname());
exit(0);

function printUsage(string $msg) {
    if (isset($msg)) {
        fwrite(STDERR, $msg."\n");
    }
    fwrite(STDERR, "Usage:\n");
    fwrite(STDERR, "./get_connected_folder.php --folder=<path> [--direction=next|previous]\n");
    fwrite(STDERR, "\nif direction is ommitted 'next' will be used.\n");
    exit(255);
}

?>

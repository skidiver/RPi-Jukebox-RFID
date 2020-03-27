#!/usr/bin/php
<?php
/*
* This script determines the name/path of a connected folder.
* Parameters:
* --folder=<folderName> : name (not full path) of the folder to look into (required)
* --direction=next|previous : look for the next/previous connected folder (optional, default=next)
* --fqn : add this option if the fully qualified path of the connected folder has to be written to stdout (optional, default is short folder name)
*
* Examples below
* Note: folder in '' to support whitespaces in folder names
* ./get_connected_folder.php --folder="ZZZ-SubMaster" --direction="next"
* ./get_connected_folder.php --folder="ZZZ-SubMaster" --direction="previous"
* ./get_connected_folder.php --folder="ZZZ-SubMaster" --direction="next" --fqn
* ./get_connected_folder.php --folder="ZZZ-SubMaster" --fqn
*/

declare(strict_types=1);

// includes
include_once(__DIR__.'/../htdocs/inc.loadClassesByName.php');

/*
* Get params from command line
*/
$params = getopt("", array("folder:", "direction::", "fqn::"));
if (!array_key_exists('folder', $params)) {
    printUsage("Parameter 'folder' is missing!");
}

$folderName = $params['folder'];

if (array_key_exists('direction', $params)) {
    $direction = $params['direction'];
} else {
    $direction = 'next'; // next is default
}

if (array_key_exists('fqn', $params)) {
    $fqn = true;
} else {
    $fqn = false;
}

$epCon = EpisodeConnection::fromFolderName($folderName);
if($direction !== 'previous') { // next is default
    $connection = $epCon->getNext();
} else {
    $connection = $epCon->getPrevious();
}

if (!isset($connection)) {
    exit(1);
}

if ($fqn) {
    print($connection->getRealPath());
} else {
    print($connection->getFilename());
}
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

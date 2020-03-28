#!/usr/bin/php
<?php
/*
* This script connects folders contained inside a parent folder. The folders are connected in lexicographical order
* Parameters:
* --parent=<path> : path of the parent folder (required)
* --exclude=<regex> : regular expression that matches all folders (short name) that have to be excluded (optional, default=<none>)
*
* Return codes:
* 0 - everything fine
* 255 - command line args invalid
*
* Examples below
* Note: folder in '' to support whitespaces in folder names
* ./connect_folders.php --parent="./series_abc"
* ./connect_folders.php --parent="./series_xyz" --exclude=.+S05.*
*/

declare(strict_types=1);

// includes
include_once(__DIR__.'/../htdocs/inc.loadClassesByName.php');

/*
* Get params from command line
*/
$params = getopt("", array("parent:", "exclude::"));
if (!array_key_exists('parent', $params)) {
    printUsage("Parameter 'parent' is missing!");
}

$parentFolder = new SplFileInfo($params['parent']);
try {
    Checks::requireFolder($parentFolder);
} catch (FileAccessException $e) {
    printUsage($e->getMessage());
}

if (array_key_exists('exclude', $params)) {
    $excludeRegex = $params['exclude'];
} else {
    $excludeRegex = null;
}

$entries = scandir( $parentFolder->getRealPath());
$count = count($entries);
for ($idx = 0; $idx < $count; $idx++) {
    $curr = fqn($parentFolder, $entries[$idx]); 
    if (!isIncluded($curr, $excludeRegex)) {
        continue; // skip non-included
    }

    $previous = findPrevious($entries, $idx, $parentFolder, $excludeRegex);
    $next = findNext($entries, $idx, $parentFolder, $excludeRegex);

    $epCon = EpisodeConnection::fromFileInfo($curr);
    $epCon->setNext($next);
    $epCon->setPrevious($previous);
    $epCon->store();
}

function findNext(array $entries, int $currIdx, SplFileInfo $parentFolder, ?string $excludeRegex = null) : ?SplFileInfo {
    if ($currIdx >= count($entries)-1) {
        return null;
    }

    $next = fqn($parentFolder, $entries[$currIdx+1]); 
    if (!isIncluded($next, $excludeRegex)) {
        return findNext($entries, $currIdx+1, $parentFolder, $excludeRegex);
    }
    return $next;
}

function findPrevious(array $entries, int $currIdx, SplFileInfo $parentFolder, ?string $excludeRegex = null) : ?SplFileInfo {
    if ($currIdx <= 0) {
        return null;
    }

    $previous = fqn($parentFolder, $entries[$currIdx-1]); 
    if (!isIncluded($previous, $excludeRegex)) {
        return findPrevious($entries, $currIdx-1, $parentFolder, $excludeRegex);
    }
    return $previous;
}

exit(0);

function fqn(SplFileInfo $parent, string $childName) : SplFileInfo {
    return new SplFileInfo($parent->getPathname() . "/" . $childName);
}

function printUsage(string $msg) {
    if (isset($msg)) {
        fwrite(STDERR, $msg."\n");
    }
    fwrite(STDERR, "Usage:\n");
    fwrite(STDERR, "./connect_folders.php --parent=<path> [--exclude=<regex>]\n");
    fwrite(STDERR, "\nif regex is ommitted no folder is excluded.\n");
    exit(255);
}

function isIncluded(SplFileInfo $entry, ?string $excludeRegex = null) : bool {
    if (!$entry->isDir()) {
        return false; // only process folders
    }
    $fileName = $entry->getFilename();
    if ($fileName === "." || $fileName === "..") {
        return false; // skip '.' and '..'
    }
    if (!isset($excludeRegex)) {
        return true; // nothing excluded
    }
    if (substr($excludeRegex, 0, 1) !== "@"){ // NOT starts with @
        $excludeRegex = "@" . $excludeRegex;
    }
    if (substr($excludeRegex, strlen($excludeRegex)-1, 1) !== "@"){ // NOT ends with @
        $excludeRegex = $excludeRegex . "@";
    }
    if (preg_match($excludeRegex, $fileName)){
        return false; // exclude matches
    }
    return true;
}

?>

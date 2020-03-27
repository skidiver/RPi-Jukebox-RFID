<?php
declare(strict_types=1);

class Checks {

    public static function requireFile(SplFileInfo $file, bool $writable = NULL) : ?SplFileInfo {
        if (!isset($writable)) {
            $writable = false;
        }
        if (!$file->isFile()) {
            throw new FileAccessException("'" . $file->getPathname() . "' does not denote a file");
        }
        if ($writable) {
            if (!$file->isWritable()) {
                throw new FileAccessException("'" . $file->getPathname() . "' is not writable");
            }
        } else {
            if (!$file->isReadable()) {
                throw new FileAccessException("'" . $file->getPathname() . "' is not readable");
            }
        }
        return $file;
    }

    public static function requireFolder(SplFileInfo $folder, bool $writable = NULL) : ?SplFileInfo {
        if (!isset($writable)) {
            $writable = false;
        }
        if (!$folder->isDir()) {
            throw new FileAccessException("'" . $folder->getPathname() . "' does not denote a directory");
        }
        if ($writable) {
            if (!$folder->isWritable()) {
                throw new FileAccessException("'" . $folder->getPathname() . "' is not writable");
            }
        } else {
            if (!$folder->isExecutable()) {
                throw new FileAccessException("'" . $folder->getPathname() . "' is not executable");
            }
        }
        return $folder;
    }
}
?>
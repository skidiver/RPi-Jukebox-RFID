<?php
declare(strict_types=1);

class EpisodeConnection {

    public const NAME_NEXT = 'next.conf';
    public const NAME_PREV = 'previous.conf';
    private $folder;
    private $next;
    private $previous;

    public function __construct(SplFileInfo $folder) {
        $this->folder = $folder;
        if (!$this->getFolder()->isDir()) {
            throw new UnexpectedValueException("'" . $this->getFolder()->getPathname() . "' does not denote a directory");
        }
        if (!$this->getFolder()->isExecutable()) {
            throw new UnexpectedValueException("'" . $this->getFolder()->getPathname() . "' is not executeable");
        }

        $this->next =  static::findConf($this->getFolder(), self::NAME_NEXT);
        $this->previous = static::findConf($this->getFolder(), self::NAME_PREV);
    }

    public static function fromPath(string $path) : EpisodeConnection {
        return EpisodeConnection::fromFileInfo(new SplFileInfo($path));
    }

    public static function fromFolderName(string $folderName) : EpisodeConnection {
        return EpisodeConnection::fromFileInfo(static::resolveFolder($folderName));
    }

    /**
     * Creates a new EpisodeConnection from a SplFileInfo
     */
    public static function fromFileInfo(SplFileInfo $fileInfo) : EpisodeConnection {
        return new EpisodeConnection($fileInfo);
    }

    /**
     * Returns the unterlying folder
     */
    public function getFolder() : SplFileInfo {
        return $this->folder;
    }

    /**
     * Creates a new EpisodeConnection denoting the parent file of this EpisodeConnection
     */
    public function parent() : EpisodeConnection {
        return new EpisodeConnection($this->getFolder()->getPathInfo());
    }

    /**
     * Checks if the (base) folder is somehow connected to another folder
     */
    public function isConnected() : bool {
        return isset($this->next) || isset($this->previous);
    }

    /**
     * Returns the folder that is connected via NAME_NEXT
     */
    public function getNext() : ?SplFileInfo {
        return $this->next;
    }

    /**
     * Sets the folder that is connected via NAME_NEXT
     */
    public function setNext(?SplFileInfo $next) {
        if (isset($next)) {
            Checks::requireFolder($next);
        }
        $this->next = $next;
    }

    /**
     * Returns the folder that is connected via NAME_PREV
     */
    public function getPrevious() : ?SplFileInfo {
        return $this->previous;
    }

    /**
     * Sets the folder that is connected via NAME_PREV
     */
    public function setPrevious(?SplFileInfo $previous) {
        if (isset($previous)) {
            Checks::requireFolder($previous);
        }
        $this->previous = $previous;
    }

    /**
     * Stores the currently set values
     */
    public function store() {
        static::storeConf($this->getFolder(), self::NAME_NEXT, $this->getNext());
        static::storeConf($this->getFolder(), self::NAME_PREV, $this->getPrevious());
    }

    /**
     * Returns the path string
     */
    public function __toString() {
        return sprintf("%s (next->%s, previous->%s)" ,$this->getFolder()->getPathname(), $this->getNext(), $this->getPrevious());
    }

    protected static function resolveFolder(string $folderName) : SplFileInfo {
        $settings = Settings::getInstance();
        return new SplFileInfo($settings->getAudioFoldersBase()->getPathname().'/'.$folderName);
    }

    /**
     * Tries to find a configuration by name inside the (base) folder
     */
    protected static function findConf(SplFileInfo $ownFolder, string $name) : ?SplFileInfo {
        $confFileName = $ownFolder->getPathname().'/'.$name;
        if (!file_exists($confFileName)) {
            return null;
        }
        $configuredValue = trim(file_get_contents($confFileName));
        $refFolder = static::resolveFolder($configuredValue);
        try {
            return Checks::requireFolder($refFolder);
        } catch(FileAccessException $e) {
            return null;
        }
    }

    /**
     * Stores a configuration (NAME_NEXT, NAME_PREV) inside ownFolder
     */
    protected static function storeConf(SplFileInfo $ownFolder, string $name, ?SplFileInfo $value) : ?SplFileInfo {
        $confFileName = $ownFolder->getPathname().'/'.$name;
        if (!isset($value)) {
            // remove conf-file if existing
            if (file_exists($confFileName)) {
                unlink($confFileName);
            }
            return null;
        }

        $result = file_put_contents($confFileName, $value->getRealPath());
        if (!$result) {
            throw new FileAccessException(sprintf("Unable to write '%s' to file '%s'", $value->getRealPath(), $confFileName));
        }
        return new SplFileInfo($confFileName);
    }
}

?>
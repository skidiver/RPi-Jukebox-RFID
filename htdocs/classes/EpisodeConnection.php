<?php
declare(strict_types=1);

class EpisodeConnection {

    public const NAME_NEXT = 'next.conf';
    public const NAME_PREV = 'previous.conf';
    private $settings;
    private $folder;
    private $next;
    private $previous;

    public function __construct(SplFileInfo $folder) {
        $this->settings = Settings::getInstance();
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
     * Returns the folder that is connected via NAME_PREV
     */
    public function getPrevious() : ?SplFileInfo {
        return $this->previous;
    }

    /**
     * Returns the path string
     */
    public function __toString() {
        return $this->getFolder()->getPathname();
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
}

?>
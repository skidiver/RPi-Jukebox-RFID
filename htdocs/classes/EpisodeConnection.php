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



        $this->next = $this->findConf(EpisodeConnection::NAME_NEXT);
        $this->previous = $this->findConf(EpisodeConnection::NAME_PREV);
        debug('next', $this->next);
        debug('previous', $this->previous);
    }

    public static function fromPath(string $path) : EpisodeConnection {
        return EpisodeConnection::fromFileInfo(new SplFileInfo($path));
    }

    public static function fromFolderName(Settings $settings, string $folderName) : EpisodeConnection {
        return EpisodeConnection::fromPath($settings->getAudioFoldersBase()->getPathname().'/'.$folderName);
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
     * Returns the path string
     */
    public function __toString() {
        return $this->getFolder()->getPathname();
    }

    protected function findConf(string $name) : ?SplFileInfo {
        $confFileName = $this->getFolder()->getPathname().'/'.$name;
        if (!file_exists($confFileName)) {
            return null;
        }
        Checks::requireFile(new SplFileInfo($confFileName));
        $refFolder = new SplFileInfo(trim(file_get_contents($confFileName)));
        Checks::requireFolder($refFolder, true);
        return $refFolder;
    }
}

?>
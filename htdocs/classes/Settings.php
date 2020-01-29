<?php
declare(strict_types=1);

class Settings {
    public const NAME_SETTINGS = 'settings';
    public const NAME_CLASSES = 'classes';
    public const NAME_AUDIO_FOLDER_PATH = 'Audio_Folders_Path';
    public const NAME_EDITION = 'edition';
    public const DEFAULT_EDITION = 'classic';
    public const NAME_VERSION = 'version';
    private $baseFolder;
    private $audioFoldersBase;
    private $edition;
    private $version;
 
    public function __construct() {       
        $this->baseFolder = new SplFileInfo(__DIR__.'/../../'.Settings::NAME_SETTINGS.'/');
        $base = $this->getBaseFolder();
        Checks::requireFolder($base);

        $this->audioFoldersBase = new SplFileInfo($this->readSetting(Settings::NAME_AUDIO_FOLDER_PATH));
        Checks::requireFolder($this->audioFoldersBase, true);

        $this->edition = $this->readSetting(Settings::NAME_EDITION, Settings::DEFAULT_EDITION);
        $this->version = $this->readSetting(Settings::NAME_VERSION);
    }

    /**
     * Returns the base folder
     */
    public function getBaseFolder() : SplFileInfo {
        return $this->baseFolder;
    }

    /**
     * Returns the audio folders base folder
     */
    public function getAudioFoldersBase() : SplFileInfo {
        return $this->audioFoldersBase;
    }

    /**
     * Returns the edition
     */
    public function getEdition() : string {
        return $this->edition;
    }

    /**
     * Returns the version
     */
    public function getVersion() : string {
        return $this->version;
    }

    /**
     * Returns this object's members
     */
    public function __toString() {
        return print_r($this, true);
    }

    protected function readSetting(string $name, string $default = NULL) : string {
        $file = $this->child($name);
        try {
            $result = $this->contentOf($file);
        } catch (Exception $e) {
            if (!isset($default)) {
                throw $e;
            }
            $result = $default;
        }
        return $result;
    }

    protected function child(string $childName) : SplFileInfo {
        $basePath = $this->getBaseFolder()->getPathname();
        $result =  new SplFileInfo($basePath.'/'.$childName);
        return $result;
    }

    protected function contentOf(SplFileInfo $file) : string {
        if (!$file->isFile()) {
            throw new UnexpectedValueException("'" . $file->getPathname() . "' does not denote a file");
        }
        if (!$file->isReadable()) {
            throw new UnexpectedValueException("'" . $file->getPathname() . "' is not readable");
        }
        return trim(file_get_contents($file->getPathname()));
    }
}

?>
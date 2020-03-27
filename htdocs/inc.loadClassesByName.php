<?php
declare(strict_types=1);
spl_autoload_register(function ($class_name) {
    include __DIR__ . '/classes/' . $class_name . '.php';
});
?>

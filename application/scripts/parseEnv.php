<?php

$filename = $argv[1];
$config = array();
if (file_exists($filename)) {
    $fileContents = file_get_contents($filename);
    $fileContents = array_filter(explode("\n", $fileContents));

    foreach ($fileContents as $line) {
        if (preg_match('/([^=]+)=(.*)/', $line, $matches)) {
            $config[$matches[1]] = !empty($matches[2]) ? $matches[2] : null;
        }
    }
}
else {
    exit(1);
}

$vars = array();
for ($i = 2; $i < count($argv); $i++) {
    $vars[] = $argv[$i];
}

foreach ($vars as $var) {
    if (array_key_exists($var, $config)) {
        echo $config[$var];
    }
    else {
        exit(1);
    }
}

<?php

require_once __DIR__.'/../../IOFrame/Util/safeSTR.php';
if(!isset($parsedownText))
    $parsedownText = 'Test!';
$testString = $parsedownText;
echo '<b>Test string is</b>: '. $testString.EOL;
$encoded = IOFrame\Util\str2SafeStr($testString);
echo '<b>Test string to safeStr is</b>: '. $encoded.EOL;
echo '<b>And back it is</b>: '. IOFrame\Util\safeStr2Str($encoded).EOL;
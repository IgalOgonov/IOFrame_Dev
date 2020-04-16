<?php
/* Just the default include for CLI files
 * */

require __DIR__ . '/../main/definitions.php';
if(!defined('SettingsHandler'))
    require __DIR__ . '/../IOFrame/Handlers/SettingsHandler.php';
if(!defined('helperFunctions'))
    require __DIR__ . '/../IOFrame/Util/helperFunctions.php';

$settings = new IOFrame\Handlers\SettingsHandler(IOFrame\Util\getAbsPath().'/'.SETTINGS_DIR_FROM_ROOT.'/localSettings/');

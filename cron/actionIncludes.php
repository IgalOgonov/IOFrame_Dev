<?php
if(!defined('actionIncludes'))
    define('actionIncludes',true);
if(!defined('RedisHandler'))
    require __DIR__ . '/../IOFrame/Handlers/RedisHandler.php';
if(!defined('LockHandler'))
    require __DIR__ . '/../IOFrame/Handlers/LockHandler.php';
if(!defined('SQLHandler'))
    require __DIR__ . '/../IOFrame/Handlers/SQLHandler.php';
if(!defined('timingManager'))
    require __DIR__ . '/../IOFrame/Util/timingManager.php';
if(!isset($settings))
    require 'defaultInclude.php';
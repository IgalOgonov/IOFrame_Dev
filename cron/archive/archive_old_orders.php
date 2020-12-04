<?php
/* Clean expired IP events*/

//Ensure this isn't accessed from the web
$interfaceName = php_sapi_name();
if ( $interfaceName !== 'cli' && (strpos( $interfaceName, 'cgi') === false) ) {
    die('This script must be accessed through the CLI (or called via the CGI by a cron job)!');
}

$actionName = 'archive/archive_old_orders';

//Includes
if(!defined('actionIncludes'))
    require __DIR__.'/../actionIncludes.php';

//Defaults
if(!defined('actionDefaults'))
    require __DIR__.'/../actionDefaults.php';

//Parameters
require __DIR__.'/../actionParams.php';
if(!isset($parameters['considerOld']))
    $parameters['considerOld'] = 3600*24*30*12;


//Try to lock the action if relevant
$lockName = 'cron_job_'.$actionName;
require __DIR__.'/../actionLock.php';

if(empty($lockFailed) || !$lockFailed){

}

//Unlock the action if relevant
require __DIR__.'/../actionUnlock.php';
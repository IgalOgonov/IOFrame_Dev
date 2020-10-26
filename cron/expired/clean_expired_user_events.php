<?php
/* Clean expired IP events*/

//Ensure this isn't accessed from the web
$interfaceName = php_sapi_name();
if ( $interfaceName !== 'cli' && strpos( $interfaceName, 'cgi' === false)) {
    die('This script must be accessed through the CLI (or called via the CGI by a cron job)!');
}

$actionName = 'expired/clean_expired_user_events';

//Includes
if(!defined('actionIncludes'))
    require __DIR__.'/../actionIncludes.php';

//Defaults
if(!defined('actionDefaults'))
    require __DIR__.'/../actionDefaults.php';

//Parameters
require __DIR__.'/../actionParams.php';


//Start the timing manager
//Try to lock the action if relevant
$lockName = 'cron_job_'.$actionName;
require __DIR__.'/../actionLock.php';
$timingManager->start();
$elapsed = $timingManager->timeElapsed();
foreach ($parameters['tables'] as $tableIndex=>$table){
    if(empty($lockFailed) || !$lockFailed){
        $parameters['tables'][$tableIndex]['finished'] = false;
    }
    else{
        $parameters['tables'][$tableIndex]['finished'] = true;
    }
    $parameters['tables'][$tableIndex]['retries'] = 0;
    $parameters['tables'][$tableIndex]['success'] = 0;
    while( (floor($elapsed/1000000) < $parameters['maxRuntime']) && !$parameters['tables'][$tableIndex]['finished'] && ($parameters['tables'][$tableIndex]['retries'] < $parameters['retries']) ){
        require __DIR__.'/../performCleanAction.php';
        $elapsed = $timingManager->timeElapsed();
    }
}
$timingManager->stop();
if($parameters['verbose'])
    foreach ($parameters['tables'] as $tableIndex=>$table){
        echo '----'.$actionName.' - '.$table['name'].'----'.EOL.
            ($table['finished']? 'Finished in ' : 'Stopped after ').floor($elapsed/1000000).'.'.(floor($elapsed/1000)%1000).' sec, '.$table['success'].' items cleaned, '.$table['retries'].' retries'.EOL;
    }

//Unlock the action if relevant
require __DIR__.'/../actionUnlock.php';
<?php
/* This single script allows dynamically running selected cron jobs, with custom parameters.
 * It does so by loading  a (potentially empty) local file.
 * HOWEVER, it also cannot work without that file, and the initial one has defaults that execute everything,
 * so it's up to each system admin to modify this file accordingly.
 *
 * Also, while this might appear a local script, all the changes it causes actually happen in the DB.
 * Thus, in multi-node systems, it might be a good idea to execute different parts of the script by each node,
 * by keeping a different subset of cron jobs enabled on each node (probably an overlapping scheme where each job is covered by 2 nodes).
 *
 * Finally, this script tries to use Redis to ensure that in the above multi-node environment, two nodes do not try to
 * execute the same script at the same time.
 * It does so by using Redis locks from LockHandler, and locking the specific cron operation.
 * The lock is only temporary - to prevent a single node failure from locking an action forever - and re-applied approximately
 * half through it's expiry if the script hasn't finished yet.
 * Also, each script has a maximum runtime (5 minutes by default - a HUGE amount of time for regular cron jobs), so a
 * lock wont ever last longer than that plus half the TTL (which is 20sec/2 by default)
 *
 * All of the last part isn't even executed if Redis isn't present, which makes sense, as a no-redis system assumes a single
 * node - and no such conflicts can ever occur.
 *
 * Supported CLI commands:
 *      -h              - Displays a help message similar to this comment
 *      -t              - Run in test mode.
 *      -s              - Silent output - otherwise, this script outputs what it does.
 *      -p              - Displays parameters and exists. Creates the default ones if they do not exist, instead.
 *      --param=<name>  - If displaying parameters, limits the output to one specific parameter (e.g. "expired/clean_expired_ip_events").
 *                        If setting a parameter, this should be the full path to set separated by dots (e.g. "expired/clean_expired_ip_events.active")
 *                        Alternatively, can be used to run just a single script, regardless of whether it's active.
 *      --set=<value>   - Used to set a parameter. Value can be anything valid (e.g, "1" and "0" can represent "true" and "false" for boolean settings).
 *                        Only works with -p and --param.
 * */
$interfaceName = php_sapi_name();
if ( $interfaceName !== 'cli' && strpos( $interfaceName, 'cgi' === false)) {
    die('This script must be accessed through the CLI (or called via the CGI by a cron job)!');
}

require 'defaultInclude.php';
if(!defined('FileHandler'))
    require __DIR__ . '/../IOFrame/Handlers/FileHandler.php';

//-------------------- Get user options --------------------
$params = [];
$flags = getopt('htsp',['param:','set:']);
//Help message
if(isset($flags['h']))
    die('Available flags are:'.EOL.'
    -h Displays this help message'.EOL.'
    [OPTIONAL]-t Run in test mode. Never silent.'.EOL.'
    [OPTIONAL]-s Silent output - verbose by default'.EOL.'
    [OPTIONAL]-p Displays parameters and exists '.EOL.'
    Creates the default ones if they do not exist, instead.'.EOL.'
    Finally, can be used to set params if --set is passed.'.EOL.'
    [OPTIONAL]--param=\<name\> If displaying parameters, limits the output'.EOL.'
    to one specific parameter (e.g. "expired/clean_expired_ip_events").'.EOL.'
    If setting a parameter, this should be the full path to set '.EOL.'
    separated by dots (e.g. "expired/clean_expired_ip_events.active")'.EOL.'
    [OPTIONAL]--set=\<value\> Used to set a parameter.'.EOL.'
    Value can be anything valid (e.g, "1" and "0"'.EOL.'
    can represent "true" and "false" for boolean settings).'.EOL.'
    ');

$test = isset($flags['t']);

$silent = !isset($flags['s']) && !$test;

$onlyParams = isset($flags['p']);

$param = isset($flags['param'])?$flags['param'] : '';

$set = isset($flags['set'])?$flags['set'] : null;

//--------------------Initialize Root DIR--------------------
$baseUrl = $settings->getSetting('absPathToRoot');

//--------------------Initialize EOL --------------------
if(!defined("EOL"))
    define("EOL",PHP_EOL);

//Attempt to load the the cron job settings - if not, create them - they'll be complete, with nothing implicit, but they'll be all inactive, and this script will exit
$cronParamsExist = file_exists($baseUrl.'localFiles/cron/parameters.json');
if(!$cronParamsExist){
    if(!is_dir($baseUrl.'localFiles/cron') && !mkdir($baseUrl.'localFiles/cron'))
        die('Cannot create params directory for some reason - most likely insufficient user privileges!');
    $createNew = fopen($baseUrl.'localFiles/cron/parameters.json','w');
    if($createNew === false)
        die('Cannot create params file for some reason - most likely insufficient user privileges!');
    else{
        fwrite($createNew,json_encode($defaultParams));
        fclose($createNew);
        die('Created new parameters json! Run again after activating them.');
    }
};

//Get Parameters
$FileHandler = new IOFrame\Handlers\FileHandler();
$cronParams = json_decode($FileHandler->readFileWaitMutex($baseUrl.'/localFiles/cron/','parameters.json',[]),true);

//Handle the case where we're only after the parameters
if($onlyParams){
    //If we're not dealing with a specific param, just display everything
    if(!$param){
        foreach ($cronParams as $paramName => $paramArr){
            echo '----- Parameters -----'.EOL;
            echo '--'.$paramName.'--'.EOL;
            foreach ($paramArr as $subName => $subValue){
                echo $subName.': '.$subValue.EOL;
            }
            echo '----'.EOL;
        }
    }
    else{
        //Either we are only displaying a single param..
        if($set === null){
            echo '--'.$param.'--'.EOL;
            if(!empty($cronParams[$param])){
                $paramArr = $cronParams[$param];
                foreach ($paramArr as $subName => $subValue){
                    echo $subName.': '.$subValue.EOL;
                }
            }
            else
                echo 'Nothing found!'.EOL;
            echo '----'.EOL;
        }
        //Or setting a new one
        else{
            $target = &$cronParams;
            $identifierArray = explode('.',$param);
            foreach ($identifierArray as $identifier){
                if(!isset($target[$identifier]))
                    die('Cannot set parameter that doesn\'t exist!');
                else
                    $target = &$target[$identifier];
            }
            $target = $set;
            try{
                $FileHandler->writeFileWaitMutex($baseUrl.'/localFiles/cron/','parameters.json',json_encode($cronParams));
            }
            catch (\Exception $e){
                die('Exception when setting new param! '.$e->getMessage());
            }
        }
    }
    die();
}

//Execute the scripts according to $cronParams, OR $param
if($param){
    if(!empty($cronParams[$param])){
        $parameters = $cronParams[$param];
        $parameters['test'] = $test;
        $parameters['verbose'] = !$silent;
        if(!is_file($param.'.php'))
            echo 'File '.$param.'.php not found!'.EOL;
        else
            require $param.'.php';
    }
    else
        echo 'Parameters for '.$param.' not found!'.EOL;
}
else{
    foreach ($cronParams as $paramName => $paramArr){
        if(!$paramArr['active'])
            continue;
        $parameters = $paramArr;
        $parameters['test'] = $test;
        $parameters['verbose'] = !$silent;
        if(!is_file($paramName))
            echo 'File '.$paramName.' not found!'.EOL;
        else
            require $paramName;
    }
}
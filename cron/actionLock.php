<?php
if(isset($RedisHandler) && isset($settings) && isset($lockName) && isset($parameters) && isset($defaultSettingsParams) && $RedisHandler->isInit){
    $lockFailed = true;
    if(!isset($LockHandler))
        $LockHandler = new IOFrame\Handlers\LockHandler($settings->getSetting('absPathToRoot').'/localFiles/temp','mutex',$defaultSettingsParams);
    $lockResult = $LockHandler->makeRedisMutex($lockName,null,[
        'sec'=> round($parameters['maxRuntime']),
        'maxWait'=> $parameters['maxRuntime'],
        'tries'=> $parameters['maxRuntime'],
        'test'=>$parameters['test'],
        'verbose'=>$parameters['verbose']
    ]);
    if(gettype($lockResult) === 'string')
        $lockFailed = false;
}
//TODO Log lock failure
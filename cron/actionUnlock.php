<?php
if(isset($RedisHandler) && $RedisHandler->isInit && isset($lockFailed) && !$lockFailed && isset($lockName) && isset($LockHandler) && isset($lockResult) && isset($parameters) ){
    $LockHandler->releaseRedisMutex($lockName,$lockResult,[
        'test'=>$parameters['test'],
        'verbose'=>$parameters['verbose']
    ]);
    //TODO
}
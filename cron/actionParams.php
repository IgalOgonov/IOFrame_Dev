<?php
if(!isset($parameters))
    $parameters = [];

if(empty($actionName) || empty($defaultParams[$actionName])){
    if(!isset($parameters['maxRuntime']))
        $parameters['maxRuntime'] = 300;
    if(!isset($parameters['retries']))
        $parameters['retries'] = 3;
    if(!isset($parameters['lockTTL']))
        $parameters['lockTTL'] = 20;
    if(!isset($parameters['batchSize']))
        $parameters['batchSize'] = 2000;
}
else{
    if(!isset($setCronJobParams))
        $setCronJobParams = function(&$parameters,$defaultParams,$key) use (&$setCronJobParams){
            if(gettype($defaultParams[$key]) === 'array'){
                if(!isset($parameters[$key]))
                    $parameters[$key] = [];
                foreach ($defaultParams[$key] as $subKey=>$value){
                    $setCronJobParams($parameters[$key],$defaultParams[$key],$subKey);
                }
            }
            else
                $parameters[$key] = $defaultParams[$key];
        };
    foreach ($defaultParams[$actionName] as $key=>$value){
        $setCronJobParams($parameters,$defaultParams[$actionName],$key);
    }

}
if(!isset($parameters['test']))
    $parameters['test'] = false;
if(!isset($parameters['verbose']))
    $parameters['verbose'] = $parameters['test'];

foreach ($parameters['tables'] as $tableIndex=>$table){
    $parameters['tables'][$tableIndex]['finished'] = false;
    $parameters['tables'][$tableIndex]['retries'] = 0;
    $parameters['tables'][$tableIndex]['success'] = 0;
}
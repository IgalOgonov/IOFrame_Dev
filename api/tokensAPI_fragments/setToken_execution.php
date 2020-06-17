<?php
$TokenHandler = new \IOFrame\Handlers\TokenHandler($settings,$defaultSettingsParams);

$result = $TokenHandler->setToken(
    $inputs['token'],
    $inputs['tokenAction'],
    $inputs['uses'] === null? 1 : $inputs['uses'],
    $inputs['ttl'] === null? -1 : $inputs['ttl'],
    [
        'test'=>$test,
        'overwrite'=>$inputs['overwrite'],
        'update'=>$inputs['update']
    ]
);
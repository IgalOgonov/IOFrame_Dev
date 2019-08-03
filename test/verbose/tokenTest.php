<?php

require_once __DIR__.'/../../IOFrame/Handlers/TokenHandler.php';
$TokenHandler = new IOFrame\Handlers\TokenHandler($settings,$defaultSettingsParams);
echo 'Setting tokens test1, test2 and test3:'.EOL;
var_dump($TokenHandler->setTokens(
    [
        'test1' => ['action'=>'test action 1','uses'=>10,'ttl'=>4000],
        'test2' => ['action'=>'test action 2','uses'=>1],
        'test3' => ['action'=>'test action 3','ttl'=>4500]
    ],
    ['test'=>true,'verbose'=>true,'overwrite'=>true]
));
echo EOL;

echo 'getting tokens test1, test2 and test3:'.EOL;
var_dump($TokenHandler->getTokens(
    ['test2','test1','test3'],
    ['test'=>true,'verbose'=>true]));
echo EOL;

echo 'consumeTokens tokens test1, test2 and test3:'.EOL;
var_dump($TokenHandler->consumeTokens(
    [
        'test1' => ['uses'=>5,'action'=>'test action 1'],
        'test2' => ['uses'=>5],
        'test3' => ['action'=>'n 3$']
    ],
    ['test'=>true,'verbose'=>true]
));
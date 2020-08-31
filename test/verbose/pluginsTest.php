<?php


echo 'Plugin mismatch exists?'.($pluginMismatch?'yes!':'no!').EOL;

echo 'Echo ordered plugins:'.EOL;
var_dump($orderedPlugins);
echo EOL;

echo 'Check if fake plugin is available:'.EOL;
var_dump($PluginHandler->getAvailable(['name'=>'hoho']));
echo EOL;

echo 'Get all available plugins:'.EOL;
var_dump($PluginHandler->getAvailable());
echo EOL;

echo 'Get info of all plugins:'.EOL;
var_dump($PluginHandler->getInfo(['test'=>true]));
echo EOL;

echo 'Get plugin order'.EOL;
$PluginHandler->getOrder(['test'=>true]);
echo EOL;


echo 'Push test1 to plugin order, don\'t varify existence:'.EOL;
var_dump(
    $PluginHandler->pushToOrder(
    'test1',
    [
        'index'=> -1,
        'verify'=> false,
        'backUp'=> false,
        'local'=> true,
        'test'=>true
    ]
    )
);
echo EOL;

echo 'Push test2 to plugin order,  varify existence:'.EOL;
var_dump(
    $PluginHandler->pushToOrder(
        'test2',
        [
            'index'=> -1,
            'verify'=> true,
            'backUp'=> false,
            'local'=> true,
            'test'=>true
        ]
    )
);
echo EOL;

echo 'Push test3 to DB plugin order, dont varify existence:'.EOL;
var_dump(
    $PluginHandler->pushToOrder(
        'test3',
        [
            'index'=> 2,
            'verify'=> false,
            'backUp'=> false,
            'local'=> false,
            'test'=>true
        ]
    )
);
echo EOL;

echo 'Removing unexisting plugin from order:'.EOL;
var_dump(
    $PluginHandler->removeFromOrder(
        'ghostTest',
        'name',
        ['verify'=>true,'backUp'=>true,'local'=>true,'test'=>true]
    )
);
echo EOL;

echo 'Removing 2nd plugin from order:'.EOL;
var_dump(
    $PluginHandler->removeFromOrder(
        1,
        'index',
        ['verify'=>true,'backUp'=>true,'local'=>true,'test'=>true]
    )
);
echo EOL;

echo 'Moving plugin 0 to 1, verifying:'.EOL;
var_dump(
    $PluginHandler->moveOrder(
        0,
        1,
        ['verify'=>true,'backUp'=>true,'local'=>true,'test'=>true]
    )
);
echo EOL;

echo 'Moving plugin 1 to 0, verifying:'.EOL;
var_dump(
    $PluginHandler->moveOrder(
        1,
        0,
        ['verify'=>true,'backUp'=>true,'local'=>true,'test'=>true]
    )
);
echo EOL;

echo 'Moving plugin 1 to 0, NOT verifying:'.EOL;
var_dump(
    $PluginHandler->moveOrder(
        1,
        0,
        ['verify'=>false,'backUp'=>true,'local'=>true,'test'=>true]
    )
);
echo EOL;

echo 'Moving plugin 1 to 0, in the DB, NOT verifying:'.EOL;
var_dump(
    $PluginHandler->moveOrder(
        1,
        0,
        ['verify'=>false,'backUp'=>true,'local'=>false,'test'=>true]
    )
);
echo EOL;

echo 'Swapping plugins 2 with 0:'.EOL;
var_dump(
    $PluginHandler->swapOrder(
        2,
        0,
        ['verify'=>true,'backUp'=>true,'local'=>true,'test'=>true]
    )
);
echo EOL;

echo 'Swapping plugins 0 with 1:'.EOL;
var_dump(
    $PluginHandler->swapOrder(
        0,
        1,
        ['verify'=>true,'backUp'=>true,'local'=>true,'test'=>true]
    )
);
echo EOL;

echo 'Swapping plugins 2 with 1:'.EOL;
var_dump(
    $PluginHandler->swapOrder(
        2,
        1,
        ['verify'=>true,'backUp'=>true,'local'=>true,'test'=>true]
    )
);
echo EOL;

echo EOL.'Ensure public images of objects,testPlugin: '.EOL; echo $PluginHandler->ensurePublicImages(['testPlugin','objects'],['test'=>true]).EOL;

echo EOL.'Check dependencies of objects: '.EOL;  $PluginHandler->checkDependencies('objects',['validate'=>true,'test'=>true]);

$optArr = array();
$optArr['testOption'] = 'hoho haha';

echo EOL.'Test plugin install:'.EOL.$PluginHandler->install('testPlugin',$optArr,['override'=>false,'test'=>true]).EOL;

echo EOL.'Test plugin 2 install:'.EOL.$PluginHandler->install('testPlugin2',$optArr,['override'=>false,'test'=>true]).EOL;

echo EOL.'Test plugin update (should reach version 20, but not 21 due to testPlugin2):'.EOL;
var_dump($PluginHandler->update('testPlugin',['test'=>true]));

echo EOL.'Test plugin update (2 iterations):'.EOL;
var_dump($PluginHandler->update('testPlugin',['test'=>true,'iterationLimit'=>2]));

echo EOL.'Test plugin 2 update (should fail critically):'.EOL;
var_dump($PluginHandler->update('testPlugin2',['test'=>true]));
<?php
if(!defined('MenuHandler'))
    require __DIR__.'/../../IOFrame/Handlers/MenuHandler.php';
$MenuHandler = new IOFrame\Handlers\MenuHandler($settings,array_merge($defaultSettingsParams,['menuIdentifier'=>'test_menu']));

echo EOL.'Setting menu items:'.EOL;
var_dump(
    $MenuHandler->setMenuItems(
        [
            [
                'address'=>[],
                'identifier'=>'test_1',
                'title'=>'1'
            ],
            [
                'address'=>[],
                'identifier'=>'test_2',
                'title'=>'2'
            ],
            [
                'address'=>[],
                'identifier'=>'test_3',
                'title'=>'3'
            ],
            [
                'address'=>['test_1'],
                'identifier'=>'test_1',
                'title'=>'1/1'
            ],
            [
                'address'=>['test_1'],
                'identifier'=>'test_2',
                'title'=>'1/2'
            ],
            [
                'address'=>['test_2'],
                'identifier'=>'test_1',
                'title'=>'2/1'
            ],
            [
                'address'=>['test_2'],
                'identifier'=>'test_3',
                'title'=>'2/3'
            ],
            [
                'address'=>['test_2','test_3'],
                'identifier'=>'test_1',
                'title'=>'2/3/1'
            ],
            [
                'address'=>['test_2','test_3'],
                'identifier'=>'test_2',
                'title'=>'2/3/2'
            ],
            [
                'address'=>['test_2','test_3'],
                'identifier'=>'test_3',
                'title'=>'2/3/3'
            ],
        ],
        ['test'=>true]
    )
);

ini_set('xdebug.var_display_max_depth', '10');
echo EOL.'Getting menu:'.EOL;
var_dump(
    $MenuHandler->getMenu(
        ['test'=>true]
    )
);

echo EOL.'Deleting menu items, modifying others:'.EOL;
var_dump(
    $MenuHandler->setMenuItems(
        [
            [
                'address'=>['test_2'],
                'identifier'=>'test_1',
                'title'=>'Edited 2/1'
            ],
            [
                'address'=>[],
                'identifier'=>'test_3',
                'title'=>'Edited 3'
            ],
            [
                'address'=>['test_2'],
                'identifier'=>'test_3',
                'delete'=>true
            ],
        ],
        ['test'=>true]
    )
);

echo EOL.'Moving one branch to another:'.EOL;
var_dump(
    $MenuHandler->moveMenuBranch(
        'test_3',
        ['test_2'],
        ['test_1'],
        ['test'=>true]
    )
);

echo EOL.'Moving one branch to existing identifier:'.EOL;
var_dump(
    $MenuHandler->moveMenuBranch(
        'test_3',
        ['test_2'],
        [],
        ['test'=>true]
    )
);




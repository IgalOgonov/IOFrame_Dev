<?php
if(!defined('MenuHandler'))
    require __DIR__.'/../../IOFrame/Handlers/MenuHandler.php';
$MenuHandler = new IOFrame\Handlers\MenuHandler($settings,$defaultSettingsParams);
ini_set('xdebug.var_display_max_depth', '10');

echo EOL.'Getting all menus'.EOL;
var_dump(
    $MenuHandler->getItems(
        [
            ['test_menu']
        ],
        'menus',
        ['test'=>true]
    )
);

echo EOL.'Creating test menu'.EOL;
var_dump(
    $MenuHandler->setItems(
        [
            [
                'Menu_ID'=>'test_menu',
                'Title'=>'Test Menu'
            ]
        ],
        'menus',
        ['test'=>true]
    )
);

echo EOL.'Deleting test menu'.EOL;
var_dump(
    $MenuHandler->deleteItems(
        [
            [
                'Menu_ID'=>'test_menu'
            ]
        ],
        'menus',
        ['test'=>true]
    )
);

echo EOL.'Setting menu items:'.EOL;
var_dump(
    $MenuHandler->setMenuItems(
        'test_menu',
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

echo EOL.'Getting menu:'.EOL;
var_dump(
    $MenuHandler->getMenu(
        'test_menu',
        ['test'=>true]
    )
);

echo EOL.'Deleting menu items, modifying others:'.EOL;
var_dump(
    $MenuHandler->setMenuItems(
        'test_menu',
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
        'test_menu',
        'test_3',
        ['test_2'],
        ['test_1'],
        ['test'=>true]
    )
);

echo EOL.'Moving one branch to existing identifier, no override:'.EOL;
var_dump(
    $MenuHandler->moveMenuBranch(
        'test_menu',
        'test_3',
        ['test_2'],
        [],
        ['test'=>true]
    )
);
echo EOL.'Moving one branch to existing identifier, override and 2nd index:'.EOL;
var_dump(
    $MenuHandler->moveMenuBranch(
        'test_menu',
        'test_3',
        ['test_2'],
        [],
        ['test'=>true,'override'=>true,'orderIndex'=>2]
    )
);


echo EOL.'Moving a branch in place (just an order update)'.EOL;
var_dump(
    $MenuHandler->moveMenuBranch(
        'test_menu',
        'test_3',
        [],
        [],
        ['test'=>true,'orderIndex'=>2]
    )
);


echo EOL.'Final movement test'.EOL;
var_dump(
    $MenuHandler->moveMenuBranch(
        'test_menu',
        'test_3',
        [],
        ['test_1','test_2'],
        ['test'=>true]
    )
);



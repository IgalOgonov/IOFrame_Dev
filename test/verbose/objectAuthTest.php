<?php
require __DIR__.'/../../IOFrame/Handlers/ObjectAuthHandler.php';

$ObjectAuthHandler = new IOFrame\Handlers\ObjectAuthHandler($settings,$defaultSettingsParams);
$IOFrameJSRoot = 'front/ioframe/js/';
$IOFrameCSSRoot = 'front/ioframe/css/';

/* ------------------------------------------------------------
                        Gets
 ------------------------------------------------------------ */

echo EOL.'Getting all categories without conditions:'.EOL;
var_dump(
    $ObjectAuthHandler->getItems(
        [],
        'categories',
        ['test'=>true,'verbose'=>true]
    )
);

echo EOL.'Getting all categories with conditions:'.EOL;
var_dump(
    $ObjectAuthHandler->getItems(
        [],
        'categories',
        [
            'titleLike'=>'t',
            'categoryIs'=>1,
            'categoryIn'=>[
                1,
                2
            ],
            'limit'=>5,
            'offset'=>0,
            'test'=>true,
            'verbose'=>true
        ]
    )
);

echo EOL.'Getting specific categories:'.EOL;
var_dump(
    $ObjectAuthHandler->getItems(
        [[1]],
        'categories',
        [
            'test'=>true,
            'verbose'=>true
        ]
    )
);


echo EOL.'Getting all objects without conditions:'.EOL;
var_dump(
    $ObjectAuthHandler->getItems(
        [],
        'objects',
        ['test'=>true,'verbose'=>true]
    )
);

echo EOL.'Getting all objects with conditions:'.EOL;
var_dump(
    $ObjectAuthHandler->getItems(
        [],
        'objects',
        [
            'titleLike'=>'t',
            'categoryIs'=>0,
            'categoryIn'=>[
                0,
                1
            ],
            'objectLike'=>'t',
            'objectIn'=>[
                'test_1',
                'test_2'
            ],
            'limit'=>5,
            'offset'=>0,
            'isPublic'=>0,
            'test'=>true,
            'verbose'=>true
        ]
    )
);

echo EOL.'Getting specific objects:'.EOL;
var_dump(
    $ObjectAuthHandler->getItems(
        [[1,'test_1']],
        'objects',
        [
            'test'=>true,
            'verbose'=>true
        ]
    )
);



echo EOL.'Getting all actions without conditions:'.EOL;
var_dump(
    $ObjectAuthHandler->getItems(
        [],
        'actions',
        ['test'=>true,'verbose'=>true]
    )
);

echo EOL.'Getting all actions with conditions:'.EOL;
var_dump(
    $ObjectAuthHandler->getItems(
        [],
        'actions',
        [
            'titleLike'=>'t',
            'categoryIs'=>0,
            'categoryIn'=>[
                0,
                1
            ],
            'actionLike'=>'t',
            'actionIn'=>[
                'test_1',
                'test_2'
            ],
            'limit'=>5,
            'offset'=>0,
            'test'=>true,
            'verbose'=>true
        ]
    )
);

echo EOL.'Getting specific actions:'.EOL;
var_dump(
    $ObjectAuthHandler->getItems(
        [[1,'test_1']],
        'actions',
        [
            'test'=>true,
            'verbose'=>true
        ]
    )
);



echo EOL.'Getting all groups without conditions:'.EOL;
var_dump(
    $ObjectAuthHandler->getItems(
        [],
        'groups',
        ['test'=>true,'verbose'=>true]
    )
);

echo EOL.'Getting all groups with conditions:'.EOL;
var_dump(
    $ObjectAuthHandler->getItems(
        [],
        'groups',
        [
            'titleLike'=>'t',
            'categoryIs'=>0,
            'categoryIn'=>[
                0,
                1
            ],
            'groupIs'=>0,
            'groupIn'=>[
                1,
                2
            ],
            'limit'=>5,
            'offset'=>0,
            'test'=>true,
            'verbose'=>true
        ]
    )
);

echo EOL.'Getting specific group:'.EOL;
var_dump(
    $ObjectAuthHandler->getItems(
        [
            [1,'test_1',1]
        ],
        'groups',
        [
            'test'=>true,
            'verbose'=>true
        ]
    )
);



echo EOL.'Getting all objectUsers without conditions:'.EOL;
var_dump(
    $ObjectAuthHandler->getItems(
        [],
        'objectUsers',
        ['test'=>true,'verbose'=>true]
    )
);

echo EOL.'Getting all objectUsers with conditions:'.EOL;
var_dump(
    $ObjectAuthHandler->getItems(
        [],
        'objectUsers',
        [
            'titleLike'=>'t',
            'categoryIs'=>1,
            'categoryIn'=>[
                0,
                1
            ],
            'userIDIs'=>1,
            'userIDIn'=>[
                1,
                2
            ],
            'actionLike'=>'t',
            'actionIn'=>[
                'test_1',
                'test_2'
            ],
            'limit'=>5,
            'offset'=>0,
            'test'=>true,
            'verbose'=>true
        ]
    )
);

echo EOL.'Getting specific objectUsers:'.EOL;
var_dump(
    $ObjectAuthHandler->getItems(
        [
            [1,'test_1',1]
        ],
        'objectUsers',
        [
            'test'=>true,
            'verbose'=>true
        ]
    )
);



echo EOL.'Getting all objectGroups without conditions:'.EOL;
var_dump(
    $ObjectAuthHandler->getItems(
        [],
        'objectGroups',
        ['test'=>true,'verbose'=>true]
    )
);

echo EOL.'Getting all objectGroups with conditions:'.EOL;
var_dump(
    $ObjectAuthHandler->getItems(
        [],
        'objectGroups',
        [
            'titleLike'=>'t',
            'categoryIs'=>1,
            'categoryIn'=>[
                0,
                1
            ],
            'groupIs'=>1,
            'groupIn'=>[
                1,
                2
            ],
            'actionLike'=>'t',
            'actionIn'=>[
                'test_1',
                'test_2'
            ],
            'limit'=>5,
            'offset'=>0,
            'test'=>true,
            'verbose'=>true
        ]
    )
);

echo EOL.'Getting specific objectGroups:'.EOL;
var_dump(
    $ObjectAuthHandler->getItems(
        [[1,'test_1',1]],
        'objectGroups',
        [
            'test'=>true,
            'verbose'=>true
        ]
    )
);



echo EOL.'Getting all userGroups without conditions:'.EOL;
var_dump(
    $ObjectAuthHandler->getItems(
        [],
        'userGroups',
        ['test'=>true,'verbose'=>true]
    )
);

echo EOL.'Getting all userGroups with conditions:'.EOL;
var_dump(
    $ObjectAuthHandler->getItems(
        [],
        'userGroups',
        [
            'titleLike'=>'t',
            'categoryIs'=>1,
            'categoryIn'=>[
                1,
                1
            ],
            'userIDIs'=>1,
            'userIDIn'=>[
                1,
                2
            ],
            'groupIs'=>1,
            'groupIn'=>[
                1,
                2
            ],
            'limit'=>5,
            'offset'=>0,
            'test'=>true,
            'verbose'=>true
        ]
    )
);

echo EOL.'Getting specific userGroups:'.EOL;
var_dump(
    $ObjectAuthHandler->getItems(
        [[1,'test_1',1]],
        'userGroups',
        [
            'test'=>true,
            'verbose'=>true
        ]
    )
);


/* ------------------------------------------------------------
                        Sets
 ------------------------------------------------------------ */

echo EOL.'Creating some categories:'.EOL;
var_dump(
    $ObjectAuthHandler->setItems(
        [
            [
                'Title' => 'test'
            ],
        ],
        'categories',
        ['test'=>true,'override'=>false,'verbose'=>true]
    )
);

echo EOL.'Updating some categories:'.EOL;
var_dump(
    $ObjectAuthHandler->setItems(
        [
            [
                'Object_Auth_Category' => 1,
                'Title' => 'test 2'
            ],
        ],
        'categories',
        ['test'=>true,'update'=>true,'verbose'=>true]
    )
);


echo EOL.'Setting some objects:'.EOL;
var_dump(
    $ObjectAuthHandler->setItems(
        [
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'Title' => 'test',
                'Is_Public' => true
            ],
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_2'
            ],
        ],
        'objects',
        ['test'=>true,'verbose'=>true]
    )
);


echo EOL.'Setting some actions:'.EOL;
var_dump(
    $ObjectAuthHandler->setItems(
        [
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Action' => 'test_1',
                'Title' => 'test'
            ],
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Action' => 'test_2',
            ],
        ],
        'actions',
        ['test'=>true,'verbose'=>true]
    )
);


echo EOL.'Creating some groups:'.EOL;
var_dump(
    $ObjectAuthHandler->setItems(
        [
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'Title' => 'test group'
            ],
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'Title' => 'test group 2'
            ],
        ],
        'groups',
        ['test'=>true,'override'=>false,'verbose'=>true]
    )
);


echo EOL.'Updating some groups:'.EOL;
var_dump(
    $ObjectAuthHandler->setItems(
        [
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'Object_Auth_Group' => 1,
                'Title' => 'test group 1'
            ]
        ],
        'groups',
        ['test'=>true,'update'=>true,'verbose'=>true]
    )
);


echo EOL.'Setting some object users:'.EOL;
var_dump(
    $ObjectAuthHandler->setItems(
        [
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'ID' => 1,
                'Object_Auth_Action' => 'test_1'
            ],
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'ID' => 1,
                'Object_Auth_Action' => 'test_2'
            ],
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'ID' => 2,
                'Object_Auth_Action' => 'test_2'
            ],
        ],
        'objectUsers',
        ['test'=>true,'verbose'=>true]
    )
);


echo EOL.'Setting some object groups:'.EOL;
var_dump(
    $ObjectAuthHandler->setItems(
        [
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'Object_Auth_Group' => 1,
                'Object_Auth_Action' => 'test_1'
            ],
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'Object_Auth_Group' => 2,
                'Object_Auth_Action' => 'test_2'
            ],
        ],
        'objectGroups',
        ['test'=>true,'verbose'=>true]
    )
);


echo EOL.'Setting some users groups:'.EOL;
var_dump(
    $ObjectAuthHandler->setItems(
        [
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'ID' => 1,
                'Object_Auth_Group' => 1
            ],
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'ID' => 1,
                'Object_Auth_Group' => 2
            ],
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'ID' => 2,
                'Object_Auth_Group' => 1
            ],
        ],
        'userGroups',
        ['test'=>true,'verbose'=>true]
    )
);


/* ------------------------------------------------------------
                        Deletes
 ------------------------------------------------------------ */

echo EOL.'Deleting some categories:'.EOL;
var_dump(
    $ObjectAuthHandler->deleteItems(
        [
            [
                'Object_Auth_Category' => 1
            ],
        ],
        'categories',
        ['test'=>true,'verbose'=>true]
    )
);


echo EOL.'Deleting some objects:'.EOL;
var_dump(
    $ObjectAuthHandler->deleteItems(
        [
            [
                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1'
            ],
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_2'
            ],
        ],
        'objects',
        ['test'=>true,'verbose'=>true]
    )
);

echo EOL.'Deleting some actions:'.EOL;
var_dump(
    $ObjectAuthHandler->deleteItems(
        [
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Action' => 'test_1'
            ],
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Action' => 'test_2',
            ],
        ],
        'actions',
        ['test'=>true,'verbose'=>true]
    )
);


echo EOL.'Deleting some groups:'.EOL;
var_dump(
    $ObjectAuthHandler->deleteItems(
        [
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'Object_Auth_Group' => 1
            ]
        ],
        'groups',
        ['test'=>true,'verbose'=>true]
    )
);


echo EOL.'Deleting some object users:'.EOL;
var_dump(
    $ObjectAuthHandler->deleteItems(
        [
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'ID' => 1,
                'Object_Auth_Action' => 'test_1'
            ],
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'ID' => 2,
                'Object_Auth_Action' => 'test_2'
            ],
        ],
        'objectUsers',
        ['test'=>true,'verbose'=>true]
    )
);


echo EOL.'Deleting some object groups:'.EOL;
var_dump(
    $ObjectAuthHandler->deleteItems(
        [
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'Object_Auth_Group' => 1,
                'Object_Auth_Action' => 'test_1'
            ],
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'Object_Auth_Group' => 2,
                'Object_Auth_Action' => 'test_2'
            ],
        ],
        'objectGroups',
        ['test'=>true,'verbose'=>true]
    )
);


echo EOL.'Deleting some users groups:'.EOL;
var_dump(
    $ObjectAuthHandler->deleteItems(
        [
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'ID' => 1,
                'Object_Auth_Group' => 1
            ],
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'ID' => 1,
                'Object_Auth_Group' => 2
            ],
        ],
        'userGroups',
        ['test'=>true,'verbose'=>true]
    )
);


/* ------------------------------------------------------------
                        Renaming
 ------------------------------------------------------------ */


echo EOL.'Renaming some objects:'.EOL;
var_dump(
    $ObjectAuthHandler->moveItems(
        [
            [
                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1'
            ],
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_2'
            ],
        ],
        [
            'Object_Auth_Category' => 5
        ],
        'objects',
        ['test'=>true,'verbose'=>true]
    )
);

echo EOL.'Renaming some actions:'.EOL;
var_dump(
    $ObjectAuthHandler->moveItems(
        [
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Action' => 'test_1'
            ],
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Action' => 'test_2',
            ],
        ],
        [

            'Object_Auth_Category' => 1
        ],
        'actions',
        ['test'=>true,'verbose'=>true]
    )
);


echo EOL.'Renaming some groups:'.EOL;
var_dump(
    $ObjectAuthHandler->moveItems(
        [
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'Object_Auth_Group' => 1
            ]
        ],
        [
            'Object_Auth_Object' => 'test_2',
        ],
        'groups',
        ['test'=>true,'verbose'=>true]
    )
);


echo EOL.'Renaming some object users:'.EOL;
var_dump(
    $ObjectAuthHandler->moveItems(
        [
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'ID' => 1,
                'Object_Auth_Action' => 'test_1'
            ],
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'ID' => 2,
                'Object_Auth_Action' => 'test_2'
            ],
        ],
        [
            'Object_Auth_Object' => 'test_2',
        ],
        'objectUsers',
        ['test'=>true,'verbose'=>true]
    )
);


echo EOL.'Renaming some object groups:'.EOL;
var_dump(
    $ObjectAuthHandler->moveItems(
        [
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'Object_Auth_Group' => 1,
                'Object_Auth_Action' => 'test_1'
            ],
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'Object_Auth_Group' => 2,
                'Object_Auth_Action' => 'test_2'
            ],
        ],
        [
            'Object_Auth_Object' => 'test_2',
        ],
        'objectGroups',
        ['test'=>true,'verbose'=>true]
    )
);


echo EOL.'Renaming some users groups:'.EOL;
var_dump(
    $ObjectAuthHandler->moveItems(
        [
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'ID' => 1,
                'Object_Auth_Group' => 1
            ],
            [

                'Object_Auth_Category' => 1,
                'Object_Auth_Object' => 'test_1',
                'ID' => 1,
                'Object_Auth_Group' => 2
            ],
        ],
        [
            'Object_Auth_Object' => 'test_2',
        ],
        'userGroups',
        ['test'=>true,'verbose'=>true]
    )
);

/* ------------------------------------------------------------
                        User Actions
 ------------------------------------------------------------ */


echo EOL.'Checking user actions that all exist (OR)'.EOL;
var_dump(
    $ObjectAuthHandler->useHasActions(
        1,
        'test_1',
        1,
        ['test_1','test_2'],
        ['actionSeparator'=>'OR','test'=>true,'verbose'=>true]
    )
);

echo EOL.'Checking user actions that all exist  (OR) - fake user'.EOL;
var_dump(
    $ObjectAuthHandler->useHasActions(
        1,
        'test_1',
        99999,
        ['test_1','test_2'],
        ['actionSeparator'=>'OR','test'=>true,'verbose'=>true]
    )
);

echo EOL.'Checking user actions that some exist (OR)'.EOL;
var_dump(
    $ObjectAuthHandler->useHasActions(
        1,
        'test_1',
        1,
        ['test_1','test_3','test_5'],
        ['actionSeparator'=>'OR','test'=>true,'verbose'=>true]
    )
);

echo EOL.'Checking user actions (AND)'.EOL;
var_dump(
    $ObjectAuthHandler->useHasActions(
        1,
        'test_1',
        1,
        ['test_1','test_2'],
        ['test'=>true,'verbose'=>true]
    )
);

echo EOL.'Checking user actions that some exist (AND)'.EOL;
var_dump(
    $ObjectAuthHandler->useHasActions(
        1,
        'test_1',
        1,
        ['test_1','test_3','test_5'],
        ['test'=>true,'verbose'=>true]
    )
);
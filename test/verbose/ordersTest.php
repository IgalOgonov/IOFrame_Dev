<?php
require __DIR__.'/../../IOFrame/Handlers/PurchaseOrderHandler.php';

$PurchaseOrderHandler = new \IOFrame\Handlers\PurchaseOrderHandler(
    $settings,
    array_merge($defaultSettingsParams, ['siteSettings'=>$siteSettings])
);

echo 'Creating new orders:'.EOL;
var_dump(
    $PurchaseOrderHandler->setOrders(
        [
            [
                -1,
                [
                    'orderInfo'=>json_encode(['test1'=>true,'test2'=>false])
                ]
            ],
            [
                -1,
                [
                    'orderInfo'=>json_encode(['test1'=>false,'test2'=>false])
                ]
            ],
        ],
        ['test'=>true,'verbose'=>true,'createNew'=>true]
    )
);
echo EOL;

echo 'Setting existing orders:'.EOL;
var_dump(
    $PurchaseOrderHandler->setOrders(
        [
            [
                1,
                [
                    'orderInfo'=>json_encode(['test2'=>true,'test3'=>false]),
                    'orderType'=>'test1'
                ]
            ],
            [
                2,
                [
                    'orderInfo'=>json_encode(['test1'=>true,'test3'=>true]),
                    'orderType'=>'test2',
                    'orderStatus'=>'testing'
                ]
            ],
        ],
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;

echo 'Getting all orders:'.EOL;
var_dump(
    $PurchaseOrderHandler->getOrders(
        [],
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;


echo 'Getting some orders (by ID):'.EOL;
var_dump(
    $PurchaseOrderHandler->getOrders(
        [1,2],
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;

echo 'Getting all orders (no filters):'.EOL;
var_dump(
    $PurchaseOrderHandler->getOrders(
        [],
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;

echo 'Getting all orders (limited):'.EOL;
var_dump(
    $PurchaseOrderHandler->getOrders(
        [],
        ['getLimitedInfo'=>true,'test'=>true,'verbose'=>true]
    )
);
echo EOL;

echo 'Getting all orders (with filters):'.EOL;
var_dump(
    $PurchaseOrderHandler->getOrders(
        [],
        [
            'createdAfter'=>0,
            'createdBefore'=>1676707745,
            'changedAfter'=>0,
            'changedBefore'=>1676707745,
            'orderBy'=>'Created',
            'orderType'=>1,
            'typeIs'=>'test2',
            'test'=>true,
            'verbose'=>true
        ]
    )
);
echo EOL;


echo 'Archiving some orders:'.EOL;
var_dump(
    $PurchaseOrderHandler->archiveOrders(
        [],
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;

echo 'Assigning some orders of user 1:'.EOL;
var_dump(
    $PurchaseOrderHandler->assignOrdersToUser(
        1,
        [
            [2,['meta'=>json_encode(['test'=>true])]],
            [3,['relationType'=>'test1']]
        ],
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;

echo 'Assigning some orders of user 2:'.EOL;
var_dump(
    $PurchaseOrderHandler->assignOrdersToUser(
        2,
        [
            [1,['relationType'=>'test2','meta'=>json_encode(['test'=>true])]],
            [3,['relationType'=>'test2']]
        ],
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;

echo 'Assigning some users of order 2:'.EOL;
var_dump(
    $PurchaseOrderHandler->assignUsersToOrder(
        2,
        [
            [1,['relationType'=>'test1']],
            [2,['meta'=>json_encode(['test'=>true])]],
            [3,['relationType'=>'test2']],
        ],
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;

echo 'Assigning some users of order 59:'.EOL;
var_dump(
    $PurchaseOrderHandler->assignUsersToOrder(
        59,
        [
            [1,['relationType'=>'test1']],
            [2,['meta'=>json_encode(['test'=>true])]]
        ],
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;

echo 'Getting orders of user 1:'.EOL;
var_dump(
    $PurchaseOrderHandler->getUserOrders(
        1,
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;

echo 'Getting orders of user 5:'.EOL;
var_dump(
    $PurchaseOrderHandler->getUserOrders(
        5,
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;

echo 'Getting users of order 2:'.EOL;
var_dump(
    $PurchaseOrderHandler->getOrderUsers(
        2,
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;

echo 'Getting users of order 5:'.EOL;
var_dump(
    $PurchaseOrderHandler->getOrderUsers(
        5,
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;

echo 'Removing users 1,2 of order 1:'.EOL;
var_dump(
    $PurchaseOrderHandler->removeUsersFromOrder(
        1,
        [1,2],
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;

echo 'Removing orders 1,2 of user 1:'.EOL;
var_dump(
    $PurchaseOrderHandler->removeOrdersFromUser(
        1,
        [1,2],
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;

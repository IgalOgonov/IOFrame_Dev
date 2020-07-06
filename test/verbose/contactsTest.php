<?php
require_once __DIR__.'/../../IOFrame/Handlers/ContactHandler.php';

$ContactHandler = new \IOFrame\Handlers\ContactHandler(
    $settings,
    'test',
    array_merge($defaultSettingsParams, ['siteSettings'=>$siteSettings])
);

echo 'Creating contacts:'.EOL;
var_dump(
    $ContactHandler->setContacts(
        [
            [
                'Test Contact 1',
                [
                    'firstName' => 'Test',
                    'lastName' => 'Testov',
                    'email' => 'test@test.com',
                    'phone' => '+972542354678',
                    'fax' => '+972542354679',
                    'contactInfo' => '{"testParam":"test1"}',
                    'country' => 'Israel',
                    'state' => 'North',
                    'city' =>  'Haifa',
                    'street' =>  'Street',
                    'zipCode' => '1234566',
                    'address' =>  '{"testParam":"test2"}',
                    'companyName' => 'Company',
                    'companyID' => '345454654',
                    'extraInfo' => '{"testParam":"test3"}',
                ]
            ],
            [
                'Test Contact 2',
                [
                    'firstName' => 'Tester',
                    'lastName' => 'Testovov',
                    'email' => 'test2@test.com',
                    'phone' => '+972542354678',
                    'fax' => '+972542354679',
                    'contactInfo' => null,
                    'country' => 'Israel',
                    'state' => 'North',
                    'city' =>  'Haifa',
                    'street' =>  'Street',
                    'zipCode' => '1234567',
                    'address' =>  '{"testParam":"test1"}',
                    'companyName' => 'Company',
                    'companyID' => '345454654',
                    'extraInfo' => null,
                ]
            ],
            [
                'Test Contact 3',
                [
                    'firstName' => 'Mr',
                    'lastName' => 'Glass',
                ]
            ],
        ],
        ['test'=>true,'verbose'=>true,'override'=>true]
    )
);
echo EOL;

echo 'Getting all types:'.EOL;
var_dump(
    $ContactHandler->getContactTypes(
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;

echo 'Getting all contacts:'.EOL;
var_dump(
    $ContactHandler->getContacts(
        [],
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;


echo 'Getting some contacts:'.EOL;
var_dump(
    $ContactHandler->getContacts(
        ['Test Contact 1','Test Contact 2'],
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;


echo 'Getting some contacts with limitations:'.EOL;
var_dump(
    $ContactHandler->getContacts(
        ['Test Contact 1','Test Contact 2'],
        [
            'firstNameLike'=>'Tes',
            'emailLike'=>'2',
            'test'=>true,
            'verbose'=>true
        ]
    )
);
echo EOL;

echo 'Deleting some contacts:'.EOL;
var_dump(
    $ContactHandler->deleteContacts(
        ['Test Contact 1','Test Contact 2'],
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;

echo 'Renaming contact:'.EOL;
var_dump(
    $ContactHandler->renameContact(
        'Test Contact 1',
        'Test Contact 21',
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;
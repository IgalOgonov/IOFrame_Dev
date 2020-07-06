<?php

if(!isset($translationTable))
    $translationTable = [];
$translationTable = array_merge($translationTable,[
    'Contact_Type'=>[
        'newName'=>'contactType'
    ],
    'Identifier'=>[
        'newName'=>'identifier'
    ],
    'First_Name'=>[
        'newName'=>'firstName'
    ],
    'Last_Name'=>[
        'newName'=>'lastName'
    ],
    'Email'=>[
        'newName'=>'email'
    ],
    'Phone'=>[
        'newName'=>'phone'
    ],
    'Fax'=>[
        'newName'=>'fax'
    ],
    'Contact_Info'=>[
        'newName'=>'contactInfo',
        'isJson'=>true
    ],
    'Country'=>[
        'newName'=>'country'
    ],
    'State'=>[
        'newName'=>'state'
    ],
    'City'=>[
        'newName'=>'city'
    ],
    'Street'=>[
        'newName'=>'street'
    ],
    'Zip_Code'=>[
        'newName'=>'zipCode'
    ],
    'Address'=>[
        'newName'=>'address',
        'isJson'=>true
    ],
    'Company_Name'=>[
        'newName'=>'companyName'
    ],
    'Company_ID'=>[
        'newName'=>'companyID'
    ],
    'Extra_Info'=>[
        'newName'=>'extraInfo',
        'isJson'=>true
    ],
    'Created_On'=>[
        'newName'=>'created'
    ],
    'Last_Updated'=>[
        'newName'=>'updated'
    ]
]);
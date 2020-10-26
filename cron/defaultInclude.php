<?php
/* Just the default include for CLI files
 * */

require __DIR__ . '/../main/definitions.php';
if(!defined('SettingsHandler'))
    require __DIR__ . '/../IOFrame/Handlers/SettingsHandler.php';
if(!defined('helperFunctions'))
    require __DIR__ . '/../IOFrame/Util/helperFunctions.php';

$settings = new IOFrame\Handlers\SettingsHandler(IOFrame\Util\getAbsPath().'/'.SETTINGS_DIR_FROM_ROOT.'/localSettings/');

if(!isset($defaultParams))
    $defaultParams = [
        'expired/clean_expired_ip_events'=>[
            'active'=>1,
            'archive'=>1,
            'maxRuntime'=>300,
            'retries'=>3,
            'batchSize'=>2000,
            'tables'=>[
                [
                    'name'=>'IP_EVENTS',
                    'identifierColumns'=>['IP','Event_Type','Sequence_Start_Time'],
                    'expiresColumn'=>'Sequence_Expires'
                ]
            ]
        ],
        'expired/clean_expired_ips'=>[
            'active'=>1,
            'archive'=>1,
            'maxRuntime'=>300,
            'retries'=>3,
            'batchSize'=>2000,
            'tables'=>[
                [
                    'name'=>'IPV4_RANGE',
                    'identifierColumns'=>['Prefix','IP_From','IP_To'],
                    'expiresColumn'=>'Expires',
                    'delimiter'=>'/'
                ],
                [
                    'name'=>'IP_LIST',
                    'identifierColumns'=>['IP'],
                    'expiresColumn'=>'Expires',
                    'delimiter'=>'/'
                ],
            ]
        ],
        'expired/clean_expired_tokens'=>[
            'active'=>1,
            'maxRuntime'=>300,
            'retries'=>3,
            'batchSize'=>10000,
            'tables'=>[
                [
                    'name'=>'IOFRAME_TOKENS',
                    'identifierColumns'=>['Token'],
                    'expiresColumn'=>'Expires'
                ]
            ]
        ],
        'expired/clean_expired_user_events'=>[
            'active'=>1,
            'archive'=>1,
            'maxRuntime'=>300,
            'retries'=>3,
            'batchSize'=>2000,
            'tables'=>[
                [
                    'name'=>'USER_EVENTS',
                    'identifierColumns'=>['ID','Event_Type','Sequence_Start_Time'],
                    'expiresColumn'=>'Sequence_Expires'
                ]
            ]
        ],
        'archive/archive_old_logins'=>[
            'active'=>0,
            'maxRuntime'=>300,
            'retries'=>3,
            'batchSize'=>10000,
            'considerOld'=>3600*24*7
        ],
        'archive/archive_old_orders'=>[
            'active'=>0,
            'maxRuntime'=>300,
            'retries'=>3,
            'batchSize'=>2000,
            'considerOld'=>3600*24*30*12
        ]
    ];
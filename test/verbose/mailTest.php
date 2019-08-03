<?php

/*
//Include mail
require_once 'IOFrame/Handlers/MailHandler.php';
$mail = new IOFrame\Handlers\MailHandler($settings,['SQLHandler'=>$this->SQLHandler,'logger'=>$this->logger,'debug'=>true]);
if($mail->removeSecToken('igal1333@hotmail.com',true)) echo 'Removed token for 1@1'.EOL;
$secToken = $mail->createSecToken('igal1333@hotmail.com');
echo 'Mail sec token for 1@1 is '.$secToken.EOL;

$mail ->  sendMailAsync( 'igal1333@hotmail.com', 'Test async Mail', $secToken, ['',$settings->getSetting('siteName').' automated mail'],
    '', '1', '{"uId":"test1","Code":"test2"}',$type = 'template' );

$mail->SMTPDebug = 3;                               // Enable verbose debug output
if ($mail->sendMailTemplate([['aacount001@gmail.com','Joe User'],['igal1333@hotmail.com']], 'Here is the subject',
    'Test memplate! oh look a %%var%%','{"var":"variable"}', ['from@example.com','Test'],'',
    [[]], [['igal1333@hotmail.com']])
)
echo 'Message sent!<br>';

require_once $settings->getSetting('absPathToRoot').'_MailHandlers/MailHandler.php';
$siteName = $settings->getSetting('siteName');
$userSettings = new IOFrame\Handlers\SettingsHandler(getAbsPath().'/localFiles/userSettings/');
$mail->setTemplate($userSettings->getSetting('regConfirmTemplate'));
if ($mail->sendMailTemplate([['igal1333@hotmail.com']],'Account activation - '.$siteName,'','{"uId":0,"Code":"1112"}',
    ['',$siteName.' automated email']))
    echo 'Message sent from Template!<br>';
*/
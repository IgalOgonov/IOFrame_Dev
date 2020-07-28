<?php


//Include mail
require_once __DIR__.'/../../IOFrame/Handlers/MailHandler.php';
$mail = new IOFrame\Handlers\MailHandler($settings,array_merge($defaultSettingsParams,['verbose'=>true]));
if($mail->removeSecToken('igal1333@hotmail.com',true)) echo 'Removed token for 1@1'.EOL;
$secToken = $mail->createSecToken('igal1333@hotmail.com');
echo 'Mail sec token for 1@1 is '.$secToken.EOL;

echo 'Getting template 1'.EOL;
var_dump(
    $mail->getTemplate(1,['test'=>true])
);
echo EOL;

echo 'Creating new template'.EOL;
var_dump(
    $mail->setTemplate(-1,'Test Title','This is a test mail!',['test'=>true,'createNew'=>true])
);
echo EOL;

echo 'Updating template'.EOL;
var_dump(
    $mail->setTemplate(3,'Test Title','This is a test mail!',['test'=>true])
);
echo EOL;

echo 'Deleting template'.EOL;
var_dump(
    $mail->deleteTemplate(3,['test'=>true])
);
echo EOL;

/*
$mail->SMTPDebug = 3;                               // Enable verbose debug output
if ($mail->sendMailTemplate([['aacount001@gmail.com','Joe User'],['igal1333@hotmail.com']], 'Here is the subject',
    'Test template! oh look a %%var%%','{"var":"variable"}', ['from@example.com','Test'],'',
    [[]], [['igal1333@hotmail.com']])
)
    echo 'Message sent!<br>';

$mail ->  sendMailAsync( 'igal1333@hotmail.com', 'Test async Mail', $secToken, ['test@ioframe.io',$settings->getSetting('siteName').' automated mail'],
    '', '1', '{"uId":"test1","Code":"test2"}',$type = 'template' );*/

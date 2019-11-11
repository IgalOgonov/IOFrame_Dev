<?php

if(!defined('UserHandler'))
    require __DIR__ . '/../../IOFrame/Handlers/UserHandler.php';

if(!isset($UserHandler))
    $UserHandler = new IOFrame\Handlers\UserHandler(
        $settings,
        $defaultSettingsParams
    );

//Attempts to send a mail to the user requiring password reset.
if(isset($inputs['mail'])){
    $result = $UserHandler->mailChangeSend($inputs['mail'],['test'=>$test]);
}

//Checks if the info provided by the user was correct, if so authorizes the Session to reset the mail for a few minutes.
//For now, depends on password reset time - due to it making sense (both are sensitive information with similar weight)
else if(isset($inputs['id']) and isset($inputs['code']) ){
    $result = $UserHandler->mailChangeConfirm($inputs['id'], $inputs['code'],['test'=>$test]);
    if(!isset($pageSettings))
        $pageSettings = new IOFrame\Handlers\SettingsHandler(
            $settings->getSetting('absPathToRoot').'/'.SETTINGS_DIR_FROM_ROOT.'/pageSettings/',
            $defaultSettingsParams
        );

    if( $result === 0 ){
        if(!$test){
            $_SESSION['MAIL_CHANGE_EXPIRES']=time()+$UserHandler->userSettings->getSetting('passwordResetTime')*60;
            $_SESSION['MAIL_CHANGE_ID']=$inputs['id'];
        }
        else{
            echo 'Changing MAIL_CHANGE_EXPIRES to '.(time()+$UserHandler->userSettings->getSetting('passwordResetTime')*60).EOL;
            echo 'Changing MAIL_CHANGE_ID to '.$inputs['id'].EOL;
        }
    }

    if(!isset($inputs['async'])  && $pageSettings->getSetting('mailReset')){
        if(!$test)
            header('Location: http://'.$_SERVER['SERVER_NAME'].'/'.$settings->getSetting('pathToRoot').$pageSettings->getSetting('mailReset').'?res='.$result);

        else
            echo 'Changing header location to http://'.$_SERVER['SERVER_NAME'].'/'.$settings->getSetting('pathToRoot').$pageSettings->getSetting('mailReset').'?res='.$result.EOL;
    }

}
else{
    if($test)
        echo 'Wrong user input.';
    $result = -1;
}


?>
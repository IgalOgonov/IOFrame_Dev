<?php
//Check auth
if(false){
    //TODO Check gallery auth and ownership
}
elseif( !( $auth->hasAction(GALLERY_UPDATE_AUTH) || $auth->isAuthorized(0) ) ){
    if($test)
        echo 'Cannot modify galleries, or their memberships!'.EOL;
    exit(AUTHENTICATION_FAILURE);
}
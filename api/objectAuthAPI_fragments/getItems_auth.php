<?php

//Auth check
if(!$auth->isAuthorized(0) && !$auth->hasAction(AUTH_VIEW) ){
    if($test)
        echo 'Must be rank 0, or have the relevant actions to view items!';
    exit(AUTHENTICATION_FAILURE);
}

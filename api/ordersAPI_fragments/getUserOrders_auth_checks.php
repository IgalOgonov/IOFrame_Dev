<?php

if(!$auth->isAuthorized(0) && !$auth->hasAction(USERS_ORDERS_VIEW_AUTH)){
    if($test)
        echo 'Only an admin may view all orders!'.EOL;
    exit(AUTHENTICATION_FAILURE);
}
<?php
if(!$auth->isAuthorized(0) && !$auth->hasAction(SECURITY_IP_AUTH) && !$auth->hasAction(SECURITY_IP_MODIFY)){
    if($test)
        echo 'Cannot modify IP rules'.EOL;
    exit(AUTHENTICATION_FAILURE);
}

//ip
if(!filter_var($inputs['ip'], FILTER_VALIDATE_IP, FILTER_FLAG_IPV4 )){
    if($test)
        echo 'IP needs to be a valid ipv4'.EOL;
    exit(INPUT_VALIDATION_FAILURE);
}
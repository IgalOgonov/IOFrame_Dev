<?php

echo "the session id is: ".session_id().EOL;
echo "Session status: ".session_status().EOL;

echo EOL."All session variables are:".EOL;

foreach($_SESSION as$key=>$value){
    if(is_Array($value))
        $value = json_encode($value);
    echo $key.': '.$value.EOL;
}
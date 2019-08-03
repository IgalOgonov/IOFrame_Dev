<?php


/*
$ch = curl_init();

curl_setopt($ch, CURLOPT_URL,"http://".$_SERVER['SERVER_NAME'].$settings->getSetting('pathToRoot')."/api/mail.php");
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_USERAGENT, 'api');
curl_setopt($ch, CURLOPT_TIMEOUT, 1);
curl_setopt($ch, CURLOPT_HEADER, 0);
curl_setopt($ch,  CURLOPT_RETURNTRANSFER, false);
curl_setopt($ch, CURLOPT_FORBID_REUSE, true);
curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 10);
curl_setopt($ch, CURLOPT_DNS_CACHE_TIMEOUT, 10);

curl_setopt($ch, CURLOPT_FRESH_CONNECT, true);
curl_setopt($ch, CURLOPT_POSTFIELDS,
    'req=test&action=mailTo&secToken=test&mail=igal1333@hotmail.com&subj=Test Subject
    &type=template&templateNum=1&varArray={"uId":"test1","Code":"test2"}');
curl_exec ($ch);

curl_close ($ch);*/
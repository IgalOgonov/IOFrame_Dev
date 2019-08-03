<?php

require_once __DIR__.'/../IOFrame/Handlers/ext/GeoIP/vendor/autoload.php';
use GeoIp2\Database\Reader;
try{
    $reader = new Reader($rootFolder.'/localFiles/geoip-db/GeoLite2-Country.mmdb');
    try{
        $record = $reader->country($_SERVER['REMOTE_ADDR']);
        print($record->country->isoCode . '#'); // 'US'
        print($record->country->name . '<br>'); // 'United States'
    }
    catch (Exception $e){
        echo 'GeoIP error! '.$e->getMessage().EOL;
    }
}
catch(\Exception $e){
    echo 'Country DB Does not exist!'.EOL;
    $countryRes='Unkonwn';
}
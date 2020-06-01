<?php

$fragmentArr = ['r','rg','c','u','d','a','ra','ga'];

foreach($fragmentArr as $fragment){

    fclose(fopen($fragment.'_checks.php','w'));
    fclose(fopen($fragment.'_execution.php','w'));
}


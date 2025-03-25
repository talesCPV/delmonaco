<?php

    if (IsSet($_POST["dir"])){
        $path = getcwd().'/../'.$_POST["dir"];
//echo $path;        
        $files = scandir($path);
        $resp = json_encode($files);
        print($resp); 
    }
?>
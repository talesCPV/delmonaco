<?php   

	if (IsSet($_POST["path"])){
	  $path = getcwd().$_POST["path"];    
      if (file_exists($path)) {
          $fp = fopen($path, "r");
          $resp = "";
          while (!feof ($fp)) {
              $resp = $resp . fgets($fp,4096);
          }
          fclose($fp);
      }
  }

	print json_encode($resp);

?>
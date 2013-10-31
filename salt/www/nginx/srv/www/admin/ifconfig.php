<html>
<head>
<title>Network Interfaces</title>
</head><body>
<h1>Network Interfaces</h1>
<pre>
<?php
$output = shell_exec('ifconfig');
echo htmlspecialchars($output);
?>
</pre>
</body>
</html>

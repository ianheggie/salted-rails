<html>
<head>
<title>Process Status</title>
</head><body>
<h1>Process Status</h1>
<pre>
<?php
$output = shell_exec('ps axww --forest -O user,pmem');
echo htmlspecialchars($output);
?>
</pre>
</body>
</html>

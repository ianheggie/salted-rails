<html>
<head>
<title>Memory Free</title>
</head><body>
<h1>Memory Free (MB)</h1>
<pre>
<?php
$output = shell_exec('free -m');
echo htmlspecialchars($output);
?>
</pre>
</body>
</html>

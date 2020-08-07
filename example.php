<html>
<head></head>
<body>

<?php
try {
    // Connect to the SQLite Database.
    $myPDO = new PDO('sqlite:/tmp/packages.db');
} catch(Exception $e) {
    die('connection_unsuccessful: ' . $e->getMessage());
}
?>

<table>

<tr>
<td>Package Name</td><td>Latest Commit</td><td></td>
</tr><tr>
<td></td><td>Author</td><td>Date</td>
</tr>

<?php

$stm = $myPDO->query("SELECT * FROM packages");
$rows = $stm->fetchAll(PDO::FETCH_NUM);

foreach($rows as $row) {

    printf("<tr><td><a href=\"/gitlist/$row[0]\">$row[0]</a></td>");
    printf("<td>$row[1]</td><td>$row[2]</td></tr>\n");
}
?>

</table>

</body>
</html>

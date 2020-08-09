<html>
<head>
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.21/css/jquery.dataTables.css">
    <link rel="stylesheet" type="text/css" href="/css/styles.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.21/js/jquery.dataTables.js"></script>
</head>
<body>

<?php
try {
    // Connect to the SQLite Database.
    $myPDO = new PDO('sqlite:/tmp/packages.db');
} catch(Exception $e) {
    die('connection_unsuccessful: ' . $e->getMessage());
}
?>

<div id="wrapper">

<table id="table_id" class="display">

<thead>
<tr>
<td>Package Name</td><td>Author</td><td>Date</td>
</tr>
</thead>

<tbody>
<?php

$stm = $myPDO->query("SELECT * FROM packages");
$rows = $stm->fetchAll(PDO::FETCH_NUM);

foreach($rows as $row) {

    printf("<tr><td><a href=\"/gitlist/$row[0]\">$row[0]</a></td>");
    printf("<td>$row[1]</td><td>$row[2]</td></tr>\n");
}
?>
</tbody>
</table>

<script>
$(document).ready( function () {
    $('#table_id').DataTable( {
        "pageLength": 25
    });
} );
</script>

<div> 
</body>
</html>

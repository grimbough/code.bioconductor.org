<div class="container">
	<div class="row">
		<div class="col-lg-7">
			<h3>Search examples:</h3>
			<dl class="row">
				<dt class="col-sm-3"><a href="search?q=matrix">matrix</a></dt>
				<dd class="col-sm-9">search for "matrix"</dd>
				<dt class="col-sm-3"><a href="search?q=matrix+or+array">matrix or array</a></dt>
				<dd class="col-sm-9">search for either "matrix" or "array"</dd>
				<dt class="col-sm-3"><a href="search?q=class+matrix">class matrix</a></span></dt>
				<dd class="col-sm-9">search for files containing both "class" and "matrix"</dd>
				<dt class="col-sm-3"><a href="search?q=class+Matrix">class Matrix</a></dt>
				<dd class="col-sm-9">search for files containing both "class" (case insensitive) and "Matrix" (case sensitive)</dd>
				<dt class="col-sm-3"><a href="search?q=class+Matrix+case:yes">class Matrix case:yes</a></dt>
				<dd class="col-sm-9">search for files containing "class" and "Matrix", both case sensitively</dd>
				<dt class="col-sm-3"><a href="search?q=%22class Matrix%22">"class Matrix"</a></dt>
				<dd class="col-sm-9">search for files with the phrase "class Matrix"</dd>
				<dt class="col-sm-3"><a href="search?q=DNAString+-RNAString">DNAString -RNAString</a></dt>
				<dd class="col-sm-9">search for files with the word "DNAString" but not the word "RNAString"</dd>
				<dt class="col-sm-3"><a href="search?q=path+file:Rd">matrix file:Rd</a></dt>
				<dd class="col-sm-9">search for the word "matrix" in files whose name contains "Rd"</dd>
				<dt class="col-sm-3"><a href="search?q=path+file:(R|r)$">matrix file:(R|r)$</a></dt>
				<dd class="col-sm-9">search for the word "matrix" in files whose name ends with either "R" or "r"</dd>
				<dt class="col-sm-3"><a href="search?q=SparseMatrix+lang%3Ac&num=50">SparseMatrix lang:c</a></dt>
				<dd class="col-sm-9">search for "SparseMatrix" in C source code</dd>
				<dt class="col-sm-3"><a href="search?q=f:%5C.R%24">f:\.R$</a></dt>
				<dd class="col-sm-9">search for files whose name ends with ".R"</dd>
				<dt class="col-sm-3"><a href="search?q=path+-file:Rd">path -file:Rd</a></dt>
				<dd class="col-sm-9">search for the word "path" excluding files whose name contains "Rd"</dd>
				<dt class="col-sm-3"><a href="search?q=foo.*bar">foo.*bar</a></dt>
				<dd class="col-sm-9">search for the regular expression "foo.*bar"</dd>
				<dt class="col-sm-3"><a href="search?q=-%28Path File%29 Stream">-(Path File) Stream</a></dt>
				<dd class="col-sm-9">search "Stream", but exclude files containing both "Path" and "File"</dd>
				<dt class="col-sm-3"><a href="search?q=-Path%5c+file+Stream">-Path\ file Stream</a></dt>
				<dd class="col-sm-9">search "Stream", but exclude files containing "Path File"</dd>
				<!--<dt class="col-sm-3"><a href="search?q=sym:data">sym:data</a></span></dt><dd class="col-sm-9">search for symbol definitions containing "data"</dd>-->
				<dt class="col-sm-3"><a href="search?q=close+r:hdf5">close r:hdf5</a></dt>
				<dd class="col-sm-9">search for "close" in repositories whose name contains "hdf5"</dd>
<!--<dt class="col-sm-3"><a href="search?q=phone+b:master">phone b:master</a></dt><dd class="col-sm-9">for Git repos, find "phone" in files in branches whose name contains "master".</dd>
	<dt class="col-sm-3"><a href="search?q=phone+b:HEAD">phone b:HEAD</a></dt><dd class="col-sm-9">for Git repos, find "phone" in the default ('HEAD') branch.</dd>-->
</dl>
</div>
<div class="col-lg-5">
	<h3>To list packages, try:</h3>
	<dl class="row">
		<dt class="col-sm-3"><a href="search?q=r:seq">r:seq</a></dt>
		<dd class="col-sm-9">list packages whose name contains "seq".</dd>
		<dt class="col-sm-3"><a href="search?q=r:Seq">r:Seq</a></dt>
		<dd class="col-sm-9">Reposity search is case sensitive. List packages whose name contains "Seq".</dd>
		<dt class="col-sm-3"><a href="search?q=r:Seq+-r:RNA">r:Seq&nbsp;&#8209;r:RNA</a></dt>
		<dd class="col-sm-9">list packages whose name contains "Seq" but not "RNA".</dd>
	</dl>
</div>
</div>
</div>

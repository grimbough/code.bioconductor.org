
<html>
{{template "head"}}
<title>Bioconductor Code Search</title>
<body>

  <div class="container-fluid">
    <div class="row" style="padding: 10px;">
    <div class="col-sm text-center">
      <img src="https://www.bioconductor.org/images/logo/jpg/bioconductor_logo_rgb.jpg" style="height: 140px;">
    </div>
    </div>  
  </div>

  <div class="jumbotron">
    <div class="container">
      <div class="row">
        <div class="col-md-12 text-center">
          <h3>Search across all Bioconductor software packages</h3>
        </div>
      </div>
      {{template "searchbox" .Last}}
    </div>
  </div>

  <div class="container">
    <div class="row">
      <div class="col-md-8">
        <h3>Search examples:</h3>
        <dl class="dl-horizontal">
          <dt><a href="search?q=matrix">matrix</a></dt><dd>search for "matrix"</dd>
          <dt><a href="search?q=matrix+or+array">matrix or array</a></dt><dd>search for either "matrix" or "array"</dd>
          <dt><a href="search?q=class+matrix">class matrix</a></span></dt><dd>search for files containing both "class" and "matrix"</dd>
          <dt><a href="search?q=class+Matrix">class Matrix</a></dt><dd>search for files containing both "class" (case insensitive) and "Matrix" (case sensitive)</dd>
          <dt><a href="search?q=class+Matrix+case:yes">class Matrix case:yes</a></dt><dd>search for files containing "class" and "Matrix", both case sensitively</dd>
          <dt><a href="search?q=%22class Matrix%22">"class Matrix"</a></dt><dd>search for files with the phrase "class Matrix"</dd>
          <dt><a href="search?q=needle+-hay">needle -hay</a></dt><dd>search for files with the word "needle" but not the word "hay"</dd>
          <dt><a href="search?q=path+file:Rd">matrix file:Rd</a></dt><dd>search for the word "matrix" in files whose name contains "Rd"</dd>
          <dt><a href="search?q=path+file:(R|r)$">matrix file:(R|r)$</a></dt><dd>search for the word "matrix" in files whose name ends with either "R" or "r"</dd>
          <dt><a href="search?q=matrix+lang%3Ac&num=50">matrix lang:c</a></dt><dd>search for "matrix" in C source code</dd>
          <dt><a href="search?q=f:%5C.R%24">f:\.R$</a></dt><dd>search for files whose name ends with ".R"</dd>
          <dt><a href="search?q=path+-file:Rd">path -file:Rd</a></dt><dd>search for the word "path" excluding files whose name contains "Rd"</dd>
          <dt><a href="search?q=foo.*bar">foo.*bar</a></dt><dd>search for the regular expression "foo.*bar"</dd>
          <dt><a href="search?q=-%28Path File%29 Stream">-(Path File) Stream</a></dt><dd>search "Stream", but exclude files containing both "Path" and "File"</dd>
          <dt><a href="search?q=-Path%5c+file+Stream">-Path\ file Stream</a></dt><dd>search "Stream", but exclude files containing "Path File"</dd>
          <!--<dt><a href="search?q=sym:data">sym:data</a></span></dt><dd>search for symbol definitions containing "data"</dd>-->
          <dt><a href="search?q=close+r:hdf5">close r:hdf5</a></dt><dd>search for "close" in repositories whose name contains "hdf5"</dd>
          <!--<dt><a href="search?q=phone+b:master">phone b:master</a></dt><dd>for Git repos, find "phone" in files in branches whose name contains "master".</dd>
          <dt><a href="search?q=phone+b:HEAD">phone b:HEAD</a></dt><dd>for Git repos, find "phone" in the default ('HEAD') branch.</dd>-->
        </dl>
      </div>
      <div class="col-md-4">
        <h3>To list packages, try:</h3>
        <dl class="dl-horizontal">
          <dt><a href="search?q=r:Affy">r:Affy</a></dt><dd>list packages whose name contains "Affy".</dd>
          <dt><a href="search?q=r:Affy+-r:Data">r:Affy -r:Data</a></dt><dd>list packages whose name contains "Affy" but not "Data".</dd>
        </dl>
      </div>
    </div>
  </div>
  <nav class="navbar navbar-default navbar-bottom">
    <div class="container">
      {{template "footerBoilerplate"}}
      <p class="navbar-text navbar-right">
        Used {{HumanUnit .Stats.IndexBytes}} mem for
        {{.Stats.Documents}} documents ({{HumanUnit .Stats.ContentBytes}})
        from {{.Stats.Repos}} repositories.
      </p>
    </div>
  </nav>
</body>
</html>

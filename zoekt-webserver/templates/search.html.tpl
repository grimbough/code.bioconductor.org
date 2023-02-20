
<html>
{{template "head"}}
<body>

  <div class="navbar navbar-default navbar-static-top p-0" role="navigation">
    <div class="container">
        <a class="navbar-brand" href="/">
          <img class="brand-square" src="/images/bioc_code_search_square.png" alt="Bioconductor Code Logo" title="Bioconductor Code Tools">
        </a>
        <span class="navbar-brand navbar-brand-centre d-none d-sm-inline">
          <img class="navbar-centre-img" src="/images/bioc_code_search_nologo.png" alt="Bioconductor Code Logo" title="Bioconductor Code Tools">
        </span>
        <p class="navbar-text navbar-right m-0">
            <a class="navbar-barlink" href="/about.html">
                <span class="fas fa-info-circle"></span>
                <span class="nav-text">&nbsp;About</span>
            </a>
        </p>
    </div>
  </div>

  <main role="main">

    <div class="jumbotron py-3">
      <div class="container">
        <div class="row">
          <div class="col-md-12 text-center">
            <h3 class="mb-3">Search across all Bioconductor software packages</h3>
          </div>
        </div>
        {{template "searchbox" .Last}}
      </div>
    </div>

    {{template "searchExamples"}}
    
  </main>
  <footer class="footer">
    <div class="container">
      <div class="row pt-3">
        <div class="col-sm-6">
          {{template "footerBoilerplate"}}
        </div>
        <div class="col-sm-6 text-right">
          <p>
            Used {{HumanUnit .Stats.IndexBytes}} mem for
            {{.Stats.Documents}} documents ({{HumanUnit .Stats.ContentBytes}})
            from {{.Stats.Repos}} repositories.
          </p>
        </div>
      </div>
    </div>
  </footer>
</body>
</html>

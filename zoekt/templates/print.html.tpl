
<html>
  {{template "head"}}
  <title>{{.Repo}}:{{.Name}}</title>
<body id="results">
  {{template "navbar" .Last}}
  <div class="container-fluid container-results" >
     <div><b>{{.Name}}</b></div>
     <div class="table table-hover table-condensed" style="overflow:auto; background: #eef;">
       {{ range $index, $ln := .Lines}}
	 <pre id="l{{Inc $index}}" class="inline-pre"><span class="noselect"><a href="#l{{Inc $index}}">{{Inc $index}}</a>: </span>{{$ln}}</pre>
       {{end}}
     </div>
  <nav class="navbar navbar-default navbar-bottom">
    <div class="container">
      {{template "footerBoilerplate"}}
      <p class="navbar-text navbar-right">
      </p>
    </div>
  </nav>
  </div>
 {{ template "jsdep"}}
</body>
</html>

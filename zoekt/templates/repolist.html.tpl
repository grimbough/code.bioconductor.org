
<html>
{{template "head"}}
<body id="results">
  <div class="container">
    {{template "navbar" .Last}}
    <div><b>
    Found {{.Stats.Repos}} repositories ({{.Stats.Documents}} files, {{HumanUnit .Stats.ContentBytes}}b content)
    </b></div>
    <table class="table table-hover table-condensed">
      <thead>
	<tr>
	  <th>Name <a href="/search?q={{.Last.Query}}&order=name">▼</a><a href="/search?q={{.Last.Query}}&order=revname">▲</a></th>
	  <th>Last updated <a href="/search?q={{.Last.Query}}&order=revtime">▼</a><a href="/search?q={{.Last.Query}}&order=time">▲</a></th>
	  <th>Branches</th>
	  <th>Size <a href="/search?q={{.Last.Query}}&order=revsize">▼</a><a href="/search?q={{.Last.Query}}&order=size">▲</a></th>
	</tr>
      </thead>
      <tbody>
	{{range .Repos}}
	<tr>
	  <td>{{if .URL}}<a href="{{.URL}}">{{end}}{{.Name}}{{if .URL}}</a>{{end}}</td>
	  <td><small>{{.IndexTime.Format "Jan 02, 2006 15:04"}}</small></td>
	  <td style="vertical-align: middle;">
	    {{range .Branches}}
	    {{if .URL}}<tt><a class="label label-default small" href="{{.URL}}">{{end}}{{.Name}}{{if .URL}}</a> </tt>{{end}}&nbsp;
	    {{end}}
	  </td>
	  <td><small>{{HumanUnit .Files}} files ({{HumanUnit .Size}})</small></td>
	</tr>
	{{end}}
      </tbody>
    </table>
  </div>

  <nav class="navbar navbar-default navbar-bottom">
    <div class="container">
      {{template "footerBoilerplate"}}
      <p class="navbar-text navbar-right">
      </p>
    </div>
  </nav>

  {{ template "jsdep"}}
</body>
</html>


<html>
{{template "head"}}
<body id="results">
  {{template "navbar" .Last}}
  <main role="main">
  <div class="container">
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
</main>

 <footer class="footer">
  <div class="container">
    <div class="row pt-3">
      <div class="col-sm-6">
        {{template "footerBoilerplate"}}
      </div>
    </div>
  </div>
</footer>

{{ template "jsdep"}}
</body>
</html>

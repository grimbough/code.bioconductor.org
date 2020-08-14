
<form action="search">
  <div class="form-group form-group-lg">
    <div class="input-group input-group-lg">
      <input class="form-control" placeholder="Search for some code..." autofocus
              {{if .Query}}
              value={{.Query}}
              {{end}}
              id="searchbox" type="text" name="q">
      <div class="input-group-btn">
        <button class="btn btn-primary">Search</button>
      </div>
    </div>
  </div>
</form>

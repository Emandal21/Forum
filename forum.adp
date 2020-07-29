<!DOCTYPE html>
<% 
  set user [ns_getcookie user ""] 
%>
<html>
  <head>
    <title>WU Forum</title>
    
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <script src="//code.jquery.com/jquery-3.2.1.min.js"></script>
    <script src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>

    <style>
      .navbar-inverse { background-color: #ccc; border-color: #ccc;}
      .navbar {border-radius: 0px; margin-bottom: 0px;}
      .jumbotron {padding-left: 2%; padding-right: 2%;}
      .badge a {color: #fff;}
      .badge a:visited {color: #fff;}
      .filter {padding-right: 2%;}
    </style>
  </head>
  <body>
    <div>    
      <nav class="navbar navbar-inverse">
      <div class="navbar-header">
        <button type="button" class="navbar-toggle collapsed"
           data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
           <span class="sr-only">Toggle navigation</span>
           <span class="icon-bar"></span>
       </button>
        <a class="navbar-brand"><img src="wu-logo.png" style="height:27px;margin:0px;padding:0px"></a>
        </div>
   <div id="navbar" class="navbar-collapse collapse">
          <ul class="nav nav-tabs">
         <if expr='$user eq ""'>
	   <li role="presentation"><a href='list.tcl'>FORUM</a></li>
	 </if>
	 <if expr='$user ne ""'>
           <li role="presentation"><a href='edit.tcl'>FORUM</a></li>
	 </if>
        <!--<li role="presentation"><a href='reset.tcl'>Reset Database</a> </li>
        <li role="presentation"><a href='status.tcl'>Status</a> </li> -->
         <ul class="nav nnav-tabs navbar-right">
            <li role="presentation">
            <if expr='$user eq ""'>
<!-- BEGIN modal dialog for login --> 
     <a href="#user-login" title="login" role="button" data-toggle="modal">
            <span class="glyphicon glyphicon-user" aria-hidden="true"></span></a> <div class="modal fade" tabindex="-1" role="dialog" id="user-login">
        <div class="modal-dialog" role="document">
        <form role="form" method="post" action="">
        <div class="modal-content">
          <div class="modal-header" style="background-color: #ccc; border-color: #ccc;">
     <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
     <h4 class="modal-title">USER</h4>
          </div>
     <div class="modal-body">
         <div class="form-group">
           <label for="user">User</label>
      <div class="input-group">
         <span class="input-group-addon" id="basic-addon1"><span class="glyphicon glyphicon-user"></span></span>
         <input type='text' class="form-control" id="user" name='user' value='' placeholder="User" aria-describedby="basic-addon1">
      </div>
         </div>
         <div class="form-group">
           <label for="title">Password</label>
      <div class="input-group">
         <span class="input-group-addon" id="basic-addon1"><span class="glyphicon glyphicon-lock"></span></span>
         <input type='password' class="form-control" id="password" name='password' value='' placeholder="Password" aria-describedby="basic-addon1">
      </div>
         </div>
         <input type='hidden' name='__id' value=''>
         <input type='hidden' name='__context' value=''>
         <input type='hidden' name='__what' value='logIn'>
         <input type='hidden' name='__action' value=''>
         <input type='hidden' name='user' value=$user>
     </div>
          <div class="modal-footer">
     <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
     <button type="submit" class="btn btn-primary" formaction="actions.tcl">Log in</button>
          </div>
         </div><!-- /.modal-content -->
         </form>
      </div><!-- /.modal-dialog -->
    </div><!-- /.modal -->
<!-- END  modal dialog for login --> 
            </if>
            <if expr='$user ne ""'> <a title="logout" href="actions.tcl?__what=logOut"><%= $user %></a> </if>
         </li>
    </ul>       
          </ul>
     </div><!--/.nav-collapse -->
      </nav>
    </div>
    <div class="page-header" style="padding-bottom:0px;">
      <h1 style="text-align:center;">WU FORUM<br><small>WU Students Community</small></h1>
    </div>
    <div class="jumbotron" style="background-color: white; padding-top: 0px">
      <%= $content %>
      <hr>
      <if expr='$user ne ""'>
      <if expr='[info exists ::p]'>New Posting: <%= [$p template eval] %><hr></if></if>
      <if expr='[info exists timings]'><br><%= $timings %></if>
    </div>
    <hr>
  </body>
</html>

<div class="modal fade" tabindex="-1" role="dialog" id="$id">
    <div class="modal-dialog" role="document">
    <form role="form" method="post" action="">
    <div class="modal-content">
      <div class="modal-header" style="background-color: #ccc; border-color: #ccc;">
	<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
	<h4 class="modal-title">Edit post @:title@</h4>
      </div>
	<div class="modal-body">
	    <div class="form-group">
	      <label for="name">New title</label>
		<div class="input-group">
  		 <span class="input-group-addon" id="basic-addon1"><span class="glyphicon glyphicon-pencil"></span></span>
  		 <input type='text' class="form-control" id="newTitle" name='newTitle' value='@:title@' placeholder="Title" aria-describedby="basic-addon1">
		</div>
	    </div>
	    <div class="form-group">
	      <label for="body">New content</label>
  		<div class="input-group">
  		 <span class="input-group-addon" id="basic-addon1"><span class="glyphicon glyphicon-pencil"></span></span>
	      <input type="text" class="form-control" id="newBody" name="newBody" value="@:body@" placeholder="Text" aria-describedby="basic-addon1">
	    </div>
 	    </div>
	     <input type='hidden' name='supplied' value='0'>
	     <input type='hidden' name='__id' value='@::_id@'>
	     <input type='hidden' name='__context' value='$context'>
	     <input type='hidden' name='__what' value='$what'>
	     <input type='hidden' name='__action' value='$action'>
	</div>
      <div class="modal-footer">
	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
	<button type="submit" class="btn btn-primary" formaction="$href">Save changes</button>
      </div>
     </div><!-- /.modal-content -->
     </form>
  </div><!-- /.modal-dialog -->
</div><!-- /.modal -->

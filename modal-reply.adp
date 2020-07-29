<div class="modal fade" tabindex="-1" role="dialog" id="$id">
    <div class="modal-dialog" role="document">
    <form role="form" method="post" action="">
    <div class="modal-content">
      <div class="modal-header" style="background-color: #ccc; border-color: #ccc;">
	<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
	<h4 class="modal-title">Reply</h4>
      </div>
	<div class="modal-body">
	    <div class="form-group">
	      <label for="author">User</label>
		<div class="input-group">
  		 <span class="input-group-addon" id="basic-addon1"><span class="glyphicon glyphicon-user"></span></span>
  		 <input type='text' class="form-control" id="author" name='author' value='' placeholder="Author" aria-describedby="basic-addon1">
		</div>
	    </div>
	    <div class="form-group">
	      <label for="reply">Reply</label>
		<div class="input-group">
  		 <span class="input-group-addon" id="basic-addon1"><span class="glyphicon glyphicon-$glyphicon"></span></span>
  		 <input type='text' class="form-control" id="reply" name='reply' placeholder="Reply" aria-describedby="basic-addon1">
		</div>
	    </div>
	     <input type='hidden' name='__id' value='@::_id@'>
	     <input type='hidden' name='__context' value='$context'>
	     <input type='hidden' name='__what' value='$what'>
	     <input type='hidden' name='__action' value='$action'>
	</div>
      <div class="modal-footer">
	<button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
	<button type="submit" class="btn btn-primary" formaction="$href">Save changes</button>
      </div>
     </div><!-- /.modal-content -->
     </form>
  </div><!-- /.modal-dialog -->
</div><!-- /.modal -->

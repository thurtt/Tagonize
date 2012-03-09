
$(document).ready( function(){
	// date controls
	$('#move_left').click( function(){scroll(7)});
	$('#move_right').click( function(){scroll(-7)});
	createCalendarSet("#date_box", new Date( parseFloat( '<%= session[:workingDate].to_i * 1000 %>' ) ), "#day_square_");
	$( '#working_<%= session[:workingDate].to_i * 1000 %>' ).show();

	// Inspire widget
	swapInspire($('#artist'));
	(function(){
	  function foo(){
	    divObjs = $('#scripty_morph_demo').find('div');
	    divObjs = jQuery.makeArray(divObjs).setTop();
	    for( i=0; i < divObjs.length; i++ ){
		      $(divObjs[i]).animate( {top: i*divObjs[i].clientHeight+'px'}, 400);
	    }
	  }
	  $('#scripty_morph_demo').click( foo );
	  foo();
	})();
});


/* partial inspire */
var view_element = null;
function setElement( element ){
	view_element = element;
}

var show_inspiration = null;
function swapInspire(insp){
	if (insp == show_inspiration)
		return;
	if (show_inspiration != null){
		show_inspiration.fadeOut( 400 ); //style.display = 'none';
	}
	show_inspiration = insp;

	show_inspiration.fadeIn( 400 ); //style.display = '';
}

  Array.prototype.setTop = function(){
      if (view_element != null){
      	var oldlist = this;
      	var newlist = [view_element];
      	for (var i=0; i<oldlist.length; i++){
      		if ( oldlist[i] != view_element ){ newlist.push( oldlist[i] );}
      	}
      	return newlist;
      }
      else{ return this;}
  };

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

function MoveTo( id, x, y ){
    $(id).animate( { left: x, top: y }, 'swing' );
}

function ScrollToDiv( id ){
    $('html,body').animate( { scrollTop: $("#"+id).offset().top }, 'slow' );
}
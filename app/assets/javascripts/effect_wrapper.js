function MoveTo( id, x, y, func ){
    $(id).animate( { left: x, top: y }, 'swing', func );
}

function ScrollToDiv( id, func ){
    $('html,body').animate( { scrollTop: $("#"+id).offset().top }, 'slow', func );
}
$(document).ready( function(){
    $('#done_button input').click( function(){
	if (flipped){
	    setupScene(2);
	    flipped = false;
	}
    });

    $('#profile_container').click( function(){
	if (!flipped){
	    setupScene(3);
	    flipped = true;
	}
    });
    
    $('#loginsignup').click( function(){
        ScrollToDiv('join_form', function(){$('#login_input').focus()}); 
    });
    
    $('#login_input').focus( function(){$('#login_tip').fadeIn(200);} );
    $('#login_input').blur( function(){$('#login_tip').fadeOut(200);} );
    $('#password_input').focus( function(){$('#password_tip').fadeIn(200);} );
    $('#password_input').blur( function(){$('#password_tip').fadeOut(200);} );
});
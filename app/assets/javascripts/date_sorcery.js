var calendarObjects = [];
var ONE_DAY = 86400000;
var SPACING = 82;
var dateParent;
var objCount = 0;
var workingDate;

function scroll( spaces ) {
    objCount =  spaces; 
    addFunc = objCount < 0  ? addRight : addLeft;
    
    postLoad();
    addFunc();
    highlightWorkingDate( false );
    workingDate = new Date( parseInt( workingDate.getTime() ) + ( -objCount * ONE_DAY )  );
    moveEverything( objCount );
    
    $( '#working_' + workingDate.getTime().toString() ).show();    
    /*new Ajax.Updater(
                     'content',
                     '/time_entries/set_date',
                     {
                        parameters:{ date: workingDate.toString() },
                        evalScripts:true,

                        onComplete: postLoad,
                        onException: postLoad,
                        onFailure: postLoad
                     }
                    );*/
    $('#content').get( 'time_entries/set_date', { date: workingDate.toString() }, postLoad );
}

function createCalendarSet( parent, date, id ){
    dateParent = parent;
    workingDate = date;
    padding = 15;
    
    xVal = 0;
    for( i = 0; i < 9; i++ ){
      tmpDate = new Date( workingDate.getTime() + (ONE_DAY * (i - 4)));
      calObj = createCalendarObject( tmpDate.getTime() );
      calendarObjects.push( calObj );
      calObj.style.left = xVal.toString() + "px";
      xVal += SPACING;
    }
    highlightWorkingDate( true );
    
    // center everything
    xPos = ( $('date_box').width() / 2 ) - ( ( SPACING * 9 )/ 2 );
    for( i = 0; i < 9; i++ ){
        moveDateBox( calendarObjects[i], xPos, null );
    }
}

function setWorkingDate( me ){
    currentDate = workingDate.getTime().toString();
    newDate = me.id;  
    distance = getDistance( currentDate, newDate );
    scroll( distance, false );   
}

function addLeft() {
    for( i = 0; i < Math.abs( objCount ); i++ ){
        // some info about the head of the list
        head = calendarObjects[0].id;
        stamp = parseInt( head );
        calObj = createCalendarObject( stamp - ONE_DAY );
        
        pos = $( head ).position();
        
        calObj.style.left = ( pos - SPACING ).toString() + "px";
        calendarObjects.unshift( calObj );
    }
}

function removeRight(){
    for( i = 0; i < Math.abs( objCount ); i++ ){
        // remove from the tail
        tailIndex = calendarObjects.length - 1;
        $(dateParent).remove( calendarObjects[tailIndex]);
    
        // clean up the reference list
        calendarObjects.pop();
    }
}

function addRight() {
    
    for ( i = 0; i < Math.abs( objCount ); i++ ) {
        // some info about the tail of the list
        tailIndex = calendarObjects.length - 1;
        tail = "#" + calendarObjects[tailIndex].id;
        stamp = parseInt( tail );
        calObj = createCalendarObject( stamp + ONE_DAY );
    
        // get the left value for the last item before we move it
        // that will be the left value for the new item.
        pos = $( tail ).position().left;
       
        // set the x position for our new beeeotch
        calObj.style.left = ( pos + SPACING ).toString() + "px";
        calendarObjects.push( calObj );
    }
}

// cleans up after the last object is moved
function removeLeft() {
    for( i = 0; i < Math.abs( objCount ); i++ ){
        // remove from the head
        $(dateParent).remove( calendarObjects[0] );
          
        // clean up the reference list
        calendarObjects.shift();       
    }
}

function getDistance( obj1, obj2 ){
    pos1 = obj1.position();
    pos2 = obj2.position();
    
    return parseInt( ( pos1.left - pos2.left ) / SPACING );
}

function moveEverything( objCount ) {
    xPos = SPACING * objCount;  
    for( calCounter = 0; calCounter < calendarObjects.length; calCounter++ ){     
        func = null;
        if ( calCounter == calendarObjects.length - 1 ) {
            func = postMove;
        }
        moveDateBox( calendarObjects[calCounter], xPos, func);
    }  
}

function moveDateBox( id, pixels, func ){
    // pixels can be negative to move left
    curPos = $(id).position().left;
    xPix = curPos + pixels;
    $(calendarObjects[i]).animate( { left: xPix, top: 0 }, 100, 'linear', func );
}

function postMove(){
    cleanup = objCount < 0 ? removeLeft : removeRight;
    highlightWorkingDate( true );
    cleanup();
}

function postLoad(){
    $( '#working_' + workingDate.getTime().toString() ).hide();   
}

function createCalendarObject( stamp ){
    var monthNames = [ "Jan", "Feb", "Mar", "Apr", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec" ];
    var dayNames = [ "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" ];
    
    date = new Date( stamp );
    
    calObj = document.createElement('div');
    calObj.setAttribute( 'id', stamp );
    calObj.className = 'day_square day_square_normal';
    
    headerDiv = document.createElement('div');
    headerDiv.className = 'month month_normal';
    headerDiv.setAttribute( 'id', 'month_' + stamp );
    headerDiv.innerHTML = monthNames[date.getMonth()];
    
    middleDiv = document.createElement('div');
    middleDiv.className = 'day';
    middleDiv.innerHTML = date.getDate();
    
    bottomDiv = document.createElement('div');
    bottomDiv.className = 'wday';
    bottomDiv.innerHTML = dayNames[date.getDay()];
    
    workingDiv = document.createElement('div');
    workingDiv.setAttribute( 'id', 'working_' + stamp );
    workingDiv.className = 'cal_working';
    workingDiv.style.display="none";
    workingDiv.innerHTML= '<img src="/assets/working.gif" width="24px" height="24px" />';
    
    calObj.appendChild( headerDiv );
    calObj.appendChild( middleDiv );
    calObj.appendChild( bottomDiv );
    calObj.appendChild( workingDiv );
    
    $(dateParent).append( calObj );
    calObj.setAttribute( 'onclick', "setWorkingDate(this)")
    return calObj;
}

function highlightWorkingDate( enableHighlight ){
    currentDate = workingDate.getTime().toString();
    header = '#month_' + currentDate;
    if ( enableHighlight ){ 
        // add higlight to the new element.
        $(header).removeClass('month_normal');
        $(currentDate).removeClass('day_square_normal');
        $(header).addClass('month_selected');
        $(currentDate).addClass('day_square_selected');
    } else {
        $(header).removeClass('month_selected');
        $(currentDate).removeClass('day_square_selected');
        $(header).addClass('month_normal');
        $(currentDate).addClass('day_square_normal');
    }
}
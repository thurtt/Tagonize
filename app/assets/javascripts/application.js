// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var winW = 630, winH = 460;
var current_scene = 1;
var revealed = null;

var email_count = 0;

function alertWindowMetrics(){
	alert("width: " + winW + ", height: " + winH + ".");
}

function getWindowMetrics(){
	if (parseInt(navigator.appVersion)>3) {
	 if (navigator.appName=="Netscape") {
	  winW = window.innerWidth;
	  winH = window.innerHeight;
	 }
	 if (navigator.appName.indexOf("Microsoft")!=-1) {
	  winW = document.body.offsetWidth;
	  winH = document.body.offsetHeight;
	 }
	}
}

function windowLoad(){
	//window.scrollTo(0,1);
	getWindowMetrics();
	Effect.ScrollTo('thebod');
	
}
// Animation. This will be done with scenes.
function setupScene(scene){
	current_scene = scene;
	getWindowMetrics(); //get any new window metrics
	_x = 0; //Right now we only animate on the y value.
	_y = 0; // this is where we do our magic.
	switch(scene){
	case 1:
		//login
		_y = winH * 3;
		new Effect.Move('bottom_container',{ x: _x, y: _y, mode: "absolute"  });
		break;
	case 2:
		//reveal lower thingo.
		_y = 260;
		new Effect.Move('bottom_container',{ x: _x, y: _y, mode: "absolute"  });
		break;
	case 3:
		//reveal top, but not login thingo.
		//_y = winH * .70;
		base = 260;
		emails = (email_count) * 50;
		submission = 215;
		_y = base + emails + submission;
		//if (_y < 550 )
		//	_y = 550;
		new Effect.Move('bottom_container',{ x: _x, y: _y, mode: "absolute"  });
		break;
	default:
		// I have no idea.
		//alert('boo.');
	}
	
}
function resetScene(){
	getWindowMetrics();
	setupScene(current_scene);
}
window.onresize = resetScene;

function toggleSlide( me, object ) {
	y1 = $(me).cumulativeOffset().toArray()[1];
	y2 = $(object).cumulativeOffset().toArray()[1];
	
	if ( y2 - y1 < $(object).clientHeight - 12 ) {
		dist = $(object).clientHeight - 12;	
	} else {
		dist = -($(object).clientHeight - 12);
	}
	
	new Effect.Move( object, { x: 0, y: dist, mode: 'relative' });
}

function updateTitle(title){
	document.title = title + " | Tagonize.com";
}

function valRange( begin, end, step ){
	var result = [];
	for (var val = begin; val <= end; val += step){
		result.push(val);
	}
	return result;
}
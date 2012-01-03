var showing_comment = null;
var showing_hidden_efforts = null; //we're not showing them atm.
var mutedEfforts = [];

function formatEffortTime( me, minutes ){
	if( minutes == 0 ){
		me.addClassName('project_time_gray');
	} else {
		me.removeClassName('project_time_gray');
	}
	return formatMinutes( me, minutes );
}
function formatMinutes( me, minutes ){
	hours = parseInt( minutes / 60 );
	mins = minutes % 60;
	strHours = "";
	strMins = "";
	if( hours > 0 ){
		strHours = hours.toString() + "h ";
	}
	if( ( mins == 0 && hours == 0 ) || ( mins > 0 ) ) {
		strMins = Math.round( mins ).toString() + "m";
	}
	me.innerHTML = strHours + strMins;
}

function revealCollab(coll){
	document.getElementById(coll).style.display = "";
	if ((revealed != null) && (revealed != document.getElementById(coll))){
		revealed.style.display = "none";
	}
	revealed = document.getElementById(coll);
}

function revealComment(comm){
	document.getElementById(comm).style.display = "";
	if ((showing_comment != null) && (showing_comment != document.getElementById(comm))){
		showing_comment.style.display = "none";
	}
	showing_comment = document.getElementById(comm);
}

tags = new Array(0);

function addTag(element_object, taginfo_id){
	tags.push(new Array(element_object, taginfo_id));
}

function highlightTag(taginfo_id, cname){
	for (var i = 0; i < tags.length; i++) {
		if (tags[i][1] == taginfo_id)
			tags[i][0].className = cname;
	}
}

function createSlider( effort_id ){
	new Control.Slider(
			   $('effort_button_' + effort_id ),
			   $('effort_slider_' + effort_id ),
			   { 	range: $R(0, 1440),
				values: valRange( 0, 1440, 15 ),
				sliderValue: $('minutes_' + effort_id ).value,
				onSlide: function( time ) { formatEffortTime( $('project_minutes_' + effort_id), time ) },
				onChange: function( time ){
								formatEffortTime( $('project_minutes_' + effort_id), time );
								$('minutes_' + effort_id).value = time;
								new Ajax.Updater('project_overview',
										 '/time_entries/update_time_entry',
										 {
											asynchronous:true,
											evalScripts:true,
											onComplete:function(request){Element.hide('time_entry_working_' + effort_id)}, 
											onLoading:function(request){Element.show('time_entry_working_' + effort_id)}, 
											parameters:Form.serialize($('form_' + effort_id))
										 });
							   }
			   }
			);
}

function showNote( id ){
	if( $('comment_' + id ).value.length > 0  ){
		$('comment_icon_' + id ).style.visibility = "visible";
	} else {
		$('comment_icon_' + id ).style.visibility = "hidden";
	}	
}
function updateCommentary( id ){
	showNote( id );
	new Ajax.Updater('project_overview',
			 '/time_entries/update_time_entry',
			 {
				asynchronous:true,
				evalScripts:true,
				onComplete:function(request){Element.hide('time_entry_working_' + id)}, 
				onLoading:function(request){Element.show('time_entry_working_' + id)}, 
				parameters:Form.serialize($('form_' + id))
			 });
}

function showNewTag( id ){	
	new Effect.Appear( 'add_tag_' + id, { afterFinish: function(){$('taginfo_name_' + id).focus()} } );	
}
function hideNewTag( id ){
	if ( $('taginfo_name_' + id).value == '' ){
		new Effect.Fade( 'add_tag_' + id );
	}	
}

var editingTagName;
function editTag( id ){
    Element.hide( 'tag_id_' + id );
    Element.show( 'edit_tag_' + id );
    editingTagName = $('taginfo_name_edit_' + id).value;
    $('taginfo_name_edit_' + id).focus(); 
}

function updateTag( id ){
    if ( $('taginfo_name_edit_' + id ).value == editingTagName || $('taginfo_name_edit_' + id ).value == "" ){
	Effect.Fade( 'edit_tag_' + id, { afterFinish: function(){ Element.show( 'tag_id_' + id ) } } );
    } else {
	$( 'form_update_tag_' + id ).onsubmit();
    }  
}

/*******
 MUTING PROJECTS AND EFFORT
********/
function hideProject( id ){
	Element.hide('project_graph_' + id);
	Element.hide('effort_list_' + id);
	Effect.SlideUp('project_details_' + id );
}
function unhideProject( id ){
	Effect.SlideDown('project_details_' + id );
	Element.show('project_graph_' + id);
	Element.show('effort_list_' + id);
}

function hideEffort( id, project_switch ){
	if ( containsEffort(id) == 0 ){
		mutedEfforts.push([project_switch, id, false]); //project:effort_div == key:value
		updateEffortSwitch(project_switch);
		Effect.SlideUp('effort_item_' + id ); //actually hide it.
	}
}
function unhideEffort( id,project_switch ){
	// right now this has to be already unhidden to exec this.
	// so for now, leave us alone.
	removeEffortFromList( id );
	updateEffortSwitch(project_switch);
		
}
function removeEffortFromList( effort ){
	
	for(i=0; i<mutedEfforts.length; i++) { 
		if (mutedEfforts[i][1] == effort) { 
			mutedEfforts.splice(i, 1);
			return;
		}
	}
}
function lengthByKey( key ){
	ret = 0; //it does not.
	for(i=0; i<mutedEfforts.length; i++) { if (mutedEfforts[i][0] == key) { ret++; }}
	return ret;
}

function updateEffortSwitch(project_switch){
	tag_name = 'effort_toggle_switch_';
	if ( $(tag_name + project_switch) == null ) 
		return
	
	if ( lengthByKey(project_switch) > 0 ){
		$(tag_name + project_switch).innerHTML = "This project has " + lengthByKey(project_switch) + " muted tag(s). Click here to show/hide them.";
	}
	else{
		$(tag_name + project_switch).innerHTML = "";
	}
}
function containsEffort( effort ){
	ret = 0; //it does not.
	for(i=0; i<mutedEfforts.length; i++) { if (mutedEfforts[i][1] == effort) { ret = 1; }}
	return ret;
}

function toggleHiddenEfforts( project ){
	if (showing_hidden_efforts == project){
		return;
	}
	showing_hidden_efforts = project;
	
	for(i=0; i<mutedEfforts.length; i++) { 
		if ( mutedEfforts[i][0] == project ){
			if ( mutedEfforts[i][2] ){
				$('time_entry_row_' + mutedEfforts[i][1] ).style.display = 'none';
				Effect.SlideUp( $('effort_item_' + mutedEfforts[i][1]) );
			}
			else{
				Effect.SlideDown( $('effort_item_' + mutedEfforts[i][1]) );
			}
			mutedEfforts[i][2] = !mutedEfforts[i][2]
		}
	}
	showing_hidden_efforts = null;
}

function showEffortList( id ){
	$('project_graph_' + id).addClassName( 'icon_border_not_selected' );
	$('project_graph_' + id).removeClassName( 'icon_border_selected' );	
	$('effort_list_' + id).addClassName( 'icon_border_selected' );
	$('effort_list_' + id).removeClassName( 'icon_border_not_selected' );
	Effect.Fade( 'details_report_' + id, { afterFinish: function(){ Effect.Appear( 'details_effort_list_' + id ) } } );
}

function showProjectReport( id ){
	$('effort_list_' + id).addClassName( 'icon_border_not_selected' );
	$('effort_list_' + id).removeClassName( 'icon_border_selected' );
	$('project_graph_' + id).addClassName( 'icon_border_selected' );
	$('project_graph_' + id).removeClassName( 'icon_border_not_selected' );
	Effect.Fade( 'details_effort_list_' + id,
		     {
			afterFinish: function(){
						Effect.Appear( 'details_report_' + id );
						new Ajax.Updater( 'details_report_' + id,
								 '/report/generate_project_report/' + id,
								 {
								   asynchronous:true,
								   evalScripts:true,
								   onComplete:function(){
											  //Effect.Appear( 'details_report_' + id );
											}
								   }
								  );
						}
		   } );
}

function workingGIF( target ){
	$(target).innerHTML = "<img src='/assets/working.gif' height=16 width=16>"
}

function projectMute( id ){
	target = "muted_" + id;
	new Ajax.Updater(target,
			 '/time_entries/toggle_project_mute/' + id,
			 {
				asynchronous:true,
				evalScripts:true,
				//onComplete:function(request){Element.hide('time_entry_working_' + id)}, 
				onLoading:function(request){ workingGIF( target ) } 
				//parameters:Form.serialize($('form_' + id))
			 });
}

function effortMute( id ){
	target = "mutedEffort_" + id;
	new Ajax.Updater(target,
			 '/time_entries/toggle_effort_mute/' + id,
			 {
				asynchronous:true,
				evalScripts:true,
				//onComplete:function(request){Element.hide('time_entry_working_' + id)}, 
				onLoading:function(request){ workingGIF( target ) } 
				//parameters:Form.serialize($('form_' + id))
			 });
}
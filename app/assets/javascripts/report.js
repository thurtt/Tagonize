var graphList = [ "project_report_", "effort_report_", "effort_summary_", "tag_summary_" ];

function showNextGraph( project_id ) {
     
    project_id = project_id.toString();
    curGraph = graphList.shift();
    graphList.push( curGraph )
    
    switchGraphs( curGraph + project_id, graphList[0] + project_id );
}

function showPreviousGraph( project_id ) {
     
    project_id = project_id.toString();
    curGraph = graphList[0];
    newGraph = graphList.pop();
    graphList.unshift( newGraph );

    switchGraphs( curGraph + project_id, graphList[0] + project_id );
}

function switchGraphs( oldGraph, newGraph ) {
    Effect.Fade( $( oldGraph ) );
    Effect.Appear( $( newGraph) );
}
var step = 39;
function scrollDown( id ){
    new Effect.Tween( id, $(id).scrollTop, $(id).scrollTop + 39, { duration: 0.4 }, 'scrollTop' );     
}

function scrollUp( id ){
    new Effect.Tween( id, $(id).scrollTop, $(id).scrollTop - 39, { duration: 0.4 }, 'scrollTop' );
}
var globalSlider;
function scrollSlider( id ){
    boxId = $('effort_summary_box_' + id);
    scrollDistance = boxId.scrollHeight - boxId.offsetHeight;
    
    globalSlider = new Control.Slider( 'scroller_' + id, 'scroll_mouseover_' + id,
                                     {
                                        axis: 'vertical',
                                        range: $R(0, scrollDistance),
                                        values: valRange(0, scrollDistance, 1),
                                        increment: 1,
                                        onSlide: function( value ){
                                            boxId.scrollTop = value;
                                        }
                                      }
                                      );
}

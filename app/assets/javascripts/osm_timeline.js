/**
 * Created by sharonanachum on 8/10/15.
 */
function osmDayClicked(day){

//      for (var i = 0; i < 7; i++) {
//          $("#osm_day_"+i).parent().removeClass( "activePage" );
//
//      }
//
//      $('#'+day.id).parent().addClass( "activePage" );

    var day_id = "osm_day_".concat(day);

    $("#".concat(day_id)).parent().addClass( "activePage" );
}

$( document ).ready(function() {



    //var script = "$( document ).ready(function(){ $('#'.concat(<%= :osm_day_picked %>)).parent( ).addClass( 'activePage' );  });";
    //var JS= document.createElement('script');
    //JS.text= script;
    //document.head.appendChild(JS);


});
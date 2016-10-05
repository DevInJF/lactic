/**
 * Created by sharonanachum on 3/31/16.
 */
/**
 */
function lacticDayClicked(day){

    var day_id = "lactic_day_".concat(day);

    $("#".concat(day_id)).parent().addClass( "activePage" );
}

function lacticDayClicked2(day){
    var day_id = "lactic_day_".concat(day);
    for (var i=0, max=6; i <= max; i++) {
        $("#lactic_day_"+i).parent().removeClass( "activePage" );
        $("#weekly_sessions_"+i).css('display','none');
    }
    $("#".concat(day_id)).parent().addClass( "activePage" );
    $("#weekly_sessions_"+day).show();
}

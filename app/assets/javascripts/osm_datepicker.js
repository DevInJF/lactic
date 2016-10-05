/**
 * Created by sharonanachum on 8/2/15.
 */
$( document ).ready(function() {
    $(function () {
        $('.datepicker').datepicker({dateFormat: 'd-m-yy'});
        $('.anim').change(function () {
            $('.datepicker').datepicker("option", "showAnim", "fold");
        });
    });
    $(function () {
        $("#datepicker").datepicker({
            showOtherMonths: true,
            selectOtherMonths: true
        });
    });
});
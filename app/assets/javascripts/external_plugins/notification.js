/**
 * Created by sharonanachum on 1/5/16.
 */
//(function() {
//    alert(' notification');
//
//    var permToggle = document.getElementById('permission'),
//        emailToggle = document.getElementById('email'),
//        calendarToggle = document.getElementById('calendar'),
//        fbToggle = document.getElementById('fb');
//
//    var showNotificationsButton = document.getElementById('showNotifications');
//
//    var allowNotifications = false;
//
//    //var query = $('input').val();
//
//    // Notification feature detection
//    if (typeof Notification === 'function') {
//        checkPermission();
//    } else {
//        disableAllToggles();
//        alert('Your browser does not support Web Notifications API.');
//        return;
//    }
//
//    permToggle.addEventListener('change', function(e) {
//        checkPermission();
//    });
//
//
//    showNotificationsButton.addEventListener('click', function(e) {
//        showNotifications();
//    });
//
//    function disableAllToggles(){
//        permToggle.checked = false;
//        emailToggle.checked = false;
//        calendarToggle.checked = false;
//        fbToggle.checked = false;
//
//        permToggle.setAttribute('disabled', 'disabled');
//        emailToggle.setAttribute('disabled', 'disabled');
//        calendarToggle.setAttribute('disabled', 'disabled');
//        fbToggle.setAttribute('disabled', 'disabled');
//        showNotificationsButton.setAttribute('disabled', 'disabled');
//    }
//
//    function checkPermission() {
//        if(permToggle.checked === false) {
//            showNotificationsButton.setAttribute('disabled', 'disabled');
//            return;
//        }
//        Notification.requestPermission(function (status) {
//            alert('check permission');
//            if (Notification.permission !== status) {
//                Notification.permission = status;
//            }
//            if (Notification.permission === 'granted') {
//                showNotificationsButton.removeAttribute('disabled');
//            } else {
//                disableAllToggles();
//            }
//        });
//    }
//
//    function showNotifications() {
//
//        var ms = 15000; // close notification after 15 sec
//
//        alert('show notification');
//        if(emailToggle.checked) {
//            var en = new Notification('Confirm Your Payment of $500,000', {
//                body: 'From: Nigerian Prince',
//                icon: 'images/flexed-biceps.png'
//            });
//            en.onshow = function() { setTimeout(en.close, ms) }
//        }
//        if(calendarToggle.checked) {
//            var cn = new Notification('Shaolin Kung-Fu Class', {
//                body: 'Sunday, March 23 5:30 PM',
//                icon: 'images/flexed-biceps.png'
//            });
//            cn.onshow = function() { setTimeout(cn.close, ms) }
//        }
//        if(fbToggle.checked) {
//            var fn = new Notification('Chuck Norris poked you', {
//                    icon: 'images/flexed-biceps.png' }
//            );
//            fn.onshow = function() { setTimeout(fn.close, ms) }
//        }
//    }
//})();






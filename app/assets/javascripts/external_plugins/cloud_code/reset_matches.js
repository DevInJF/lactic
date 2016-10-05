///**
// * Created by sharonanachum on 1/6/16.
// */
//Parse.Cloud.job("resetMatches", function(request, status) {
//    // Set up to modify user data
//    Parse.Cloud.useMasterKey();
//    var counter = 0;
//    // Query for all users
////    var query = new Parse::Query.new("omms").greater_eq("delivery_status", 0).get;
//
//    var lactic_matches = Parse.Object.extend("lactic_match");
//    var query = new Parse.Query(lactic_matches);
//    var currentdate = new Date();
//    query.lessThan("expires_at",  currentdate);
//    //query.include("requestor,responder");
//    query.find({
//        success: function(results) {
//            alert("Successfully retrieved " + results.length + " expired matches.");
//            // Do something with the returned Parse.Object values
//            for (var i = 0; i < results.length; i++) {
//                var requestor_user = results[i].get("requestor");
//                var responder_user = results[i].get("responder");
//                // reset the user's match field at Users table to false
//
//                requestor_user.set("matched", false);
//                responder_user.set("matched", false);
//
//                requestor_user.save();
//                responder_user.save();
////                alert(omm.id + ' - ' + omm.get('from_phone_number'));
//            }
//        },
//        error: function(error) {
//            alert("Error: " + error.code + " " + error.message);
//        }
//    });
//});
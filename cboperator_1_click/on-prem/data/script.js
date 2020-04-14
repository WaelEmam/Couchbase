//create the madMen database and connect to it
var db = connect('127.0.0.1:27017/madMen'),
    allMadMen = null;
//create the names collection and add one document to it
db.names.insert({'name' : 'Don Draper'});
//add more documents to the names collection
db.names.insert({'name' : 'Peter Campbell'});
db.names.insert({'name' : 'Betty Draper'});
db.names.insert({'name' : 'Joan Harris'});


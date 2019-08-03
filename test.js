/**
data = 'bf306302e4559b3582c71efeefba62ebf7c730775cac8ef9bc3ab645d21d38c9';
var encrypted = CryptoJS.AES.encrypt(CryptoJS.enc.Utf8.parse(data),
    CryptoJS.enc.Hex.parse('bf306302e4559b3582c71efeefba62ebf7c730775cac8ef9bc3ab645d21d38c9'),
    { mode:CryptoJS.mode.ECB, padding:CryptoJS.pad.ZeroPadding});
console.log(encrypted.ciphertext.toString(CryptoJS.enc.Hex));
console.log(encrypted.ciphertext);

var params = {
    ciphertext: CryptoJS.enc.Hex.parse('359184c9479ed5dd7166a15005a3b676b0226c8ab3320b7d2267dd8bf44ca320fe30b1ebef9c06e4c3bb6fecc5c69205e66438cefee405533f0ab2269a289cbf'),
    salt: ""
};
console.log(params.ciphertext);

var decrypted = CryptoJS.AES.decrypt(encrypted,
    CryptoJS.enc.Hex.parse('bf306302e4559b3582c71efeefba62ebf7c730775cac8ef9bc3ab645d21d38c9'),
    { mode:CryptoJS.mode.ECB, padding:CryptoJS.pad.ZeroPadding});
console.log(decrypted.toString(CryptoJS.enc.Utf8));
console.log(stringDecrumble(decrypted.toString(CryptoJS.enc.Utf8),1));
console.log(stringDecrumble(decrypted.toString(CryptoJS.enc.Utf8),2));

 var obj ={};
 obj.name = 'John';
 obj.city = 'New York';
 let myJSON = JSON.stringify(obj);
 console.log(myJSON);
 obj2 = {"#": myJSON};
 myJSON2 = JSON.stringify(obj2);
 console.log(myJSON2);

 let temp = {};
 let arr =[2,0,4,0];
 arr.forEach(function (val, index){

        console.log(val+', '+index);
        if(index%2)
            temp[arr[index-1]] = arr[index];
    });
 console.log(temp); **/

 /********IndexedDB TEST!*******/
 /*
 *
// In the following line, you should include the prefixes of implementations you want to test.
window.indexedDB = window.indexedDB || window.mozIndexedDB || window.webkitIndexedDB || window.msIndexedDB;
// DON'T use "var indexedDB = ..." if you're not in a function.
// Moreover, you may need references to some window.IDB* objects:
window.IDBTransaction = window.IDBTransaction || window.webkitIDBTransaction || window.msIDBTransaction || {READ_WRITE: "readwrite"}; // This line should only be needed if it is needed to support the object's constants for older browsers
window.IDBKeyRange = window.IDBKeyRange || window.webkitIDBKeyRange || window.msIDBKeyRange;
// (Mozilla has never prefixed these objects, so we don't need window.mozIDB*)

if (!window.indexedDB) {
    window.alert("Your browser doesn't support a stable version of IndexedDB. Some features will not be available.");
}
else{
    console.log("IndexedDB available.");
}

// This is what our customer data looks like.
const customerData = [
    { ssn: "0", name: "Bill", age: 35, email: "bill2@company.com" },
    { ssn: "1", name: "Lolla", age: 27, email: "lolla2@home.org" }
];

var db;
var request = indexedDB.open("MyTestDatabase");
request.onerror = function(event) {
    alert("Why didn't you allow my web app to use IndexedDB?!");
};
request.onupgradeneeded  = function(event) {
    console.log('Here! 1');
    db = event.target.result;

    // Create an objectStore to hold information about our customers. We're
    // going to use "ssn" as our key path because it's guaranteed to be
    // unique - or at least that's what I was told during the kickoff meeting.
    var objectStore = db.createObjectStore("customers", { keyPath: "ssn" });

    // Create an index to search customers by name. We may have duplicates
    // so we can't use a unique index.
    objectStore.createIndex("name", "name", { unique: false });

    // Create an index to search customers by email. We want to ensure that
    // no two customers have the same email, so use a unique index.
    objectStore.createIndex("email", "email", { unique: true });
};

request.onsuccess = function(event){
    console.log('Here! 2');
    db = event.target.result;

    var transaction = db.transaction(["customers"], "readwrite");

    var objectStore = transaction.objectStore("customers");

    customerData.forEach(function(customer) {
        var request = objectStore.add(customer);
        console.log(customer);
        request.onsuccess = function(event) {
            console.log(event);
        };
    });

    transaction.onerror = function(event) {
        // Generic error handler for all errors targeted at this database's
        // requests!
        console.log("transaction error: ");
        console.log(event);
    };

    transaction.oncomplete = function(event) {
        console.log("All done!");
    };
};
  */

({
    logToBrowserConsole: function (component) {
        //return; //Uncomment in order to suppress all logs
        var args = Array.prototype.slice.call(arguments, 1);
        args.unshift('SoftphoneNoContact.cmp ' + ' says:\n')
        console.log.apply(console, args);
    },


})
({
    logToBrowserConsole: function (component,event,helper) {
        //return; //Uncomment in order to suppress all logs
        var args = Array.prototype.slice.call(arguments, 1);
        args.unshift('CTIUtility.cmp ' + ' says:\n')
        console.log.apply(console, args);
    },

    getParameterByName: function(component,event, input, name) {
        var anonymous = 'Anonymous';
        var inbound = 'Inbound';
        var helper = this;
        var original_input = input;
        console.log('input1: ', input);
        var input = input.replace('integrationApi/', '&');
        console.log('input2: ', input);
        //helper.logToBrowserConsole(component, 'original input: ', original_input);
        //helper.logToBrowserConsole(component,  'final input: ',input);
        console.log('name1: ', name);
        var name = name.replace(/[\[\]]/g, '\\$&');
        console.log('name2: ', name);
        var regex, results;
        if(name === 'remoteName') {
            regex = new RegExp(name + '[%0-9]*[A-Z].[%0-9]+[A-Za-z]*');
            console.log('results regex', regex);
            results = regex.exec(input);
            console.log('results remote1', results);
            if(results && results[0].includes(anonymous)) {
                console.log('return 1');
                return decodeURIComponent(anonymous);
            } else {
                console.log('return 1.1');
                return null;
            }
        } else if(name === 'direction') {
            regex = new RegExp(name + '[%0-9]*[A-Z].[%0-9]+[A-Za-z]*');
            console.log('results regex direction', regex);
            results = regex.exec(input);
            console.log('results remote1 direction', results);
            if(results && results[0].includes(inbound)) {
                console.log('return 2');
                return decodeURIComponent(inbound);
            } else {
                console.log('return 2.1');
                return null;
            }
        } else {
            regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)');
            results = regex.exec(input);
            console.log('results ', results)
        }
        if (!results) {
            console.log('return 3');
            return null;
        }
        if (!results[2]) {
            console.log('return 4');
            return '';
        }

        console.log('return 5');
        return decodeURIComponent(results[2]);
    },

})
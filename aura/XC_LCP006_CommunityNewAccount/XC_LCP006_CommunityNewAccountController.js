({
    doInit : function(cmp) {
        $A.createComponent(
            "c:XC_LCP003_NewAccount",
            {
                "isCommunity": true,
            },
            function(newButton, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    if(cmp.get("v.alreadyPush")){
                        console.log('entrato');
                        var body = cmp.get("v.body");
                        body.push(newButton);
                        cmp.set("v.body", body);
                        cmp.set("v.alreadyPush",false);
                    }
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                        // Show error message
                    }
            }
        );
        
    },
    block : function(cmp) {
        console.log('blocco il new');
        // cmp.set("v.block",false);
    },
    showModal : function(cmp) { 
        console.log('showModal');
        cmp.set("v.showModal", false);
        cmp.set("v.showModal", true);
    }
    
})
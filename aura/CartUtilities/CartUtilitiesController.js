({
	afterCheckout : function(component, event, helper)
	{
        console.log("Aftercheckout called");
		var checkoutData;
        if(event.getParam("bitwinMap") != null && event.getParam("bitwinMap") != undefined)
        {
        	checkoutData		=	event.getParam("bitwinMap")["checkOutResponse"];
            console.log("checkoutData: ",checkoutData);
            
            if (checkoutData != null && checkoutData != undefined)
            {
                var configurationId	=	checkoutData.configuration.Id;
                if (configurationId != null && configurationId != undefined)
                {
                    window.location.href	=	window.location.href;
                }
            }
        }
	}
})
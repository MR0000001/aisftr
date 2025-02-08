({
    doInit : function(component, event) {
        var action = component.get("c.callCommodity");
        var cmp = component;
        var bodyName = 'v.body0';
        action.setParams({
            'recordId': component.get("v.recordId") 
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (component.isValid() && state === "SUCCESS") {
                var responseResult = a.getReturnValue();
                if(responseResult.success){
                    var resultList = responseResult.recordFields;
                    console.log(resultList);
                    for(var index in resultList){
                        console.log(index);
                        console.log(resultList[index]);
                        $A.createComponents([
                            ["lightning:layoutItem",{
                                "flexibility":"auto",
                                "size":"12",
                                "smallDeviceSize":"5",
                                "mediumDeviceSize":"5",
                                "largeDeviceSize":"6",
                                "padding" : "horizontal-small" 
                            }],
                            ["ui:inputText",{
                                "label": resultList[index].fieldLabel,
                                "value": resultList[index].fieldValue,
                                "disabled" : true
                            }]
                        ],
                        function(components, status, errorMessage){ 
                        	var layout = components[0];
                            var input = components[1];  
                            layout.set("v.body", input);
                            var div1 = component.get(bodyName);
                            div1.push(layout);                                       
                            cmp.set(bodyName, div1);                   
                       });
                    }
                } 
                
                else {
                    component.set('v.showModal', true);
                } 
            }          
        });
        $A.enqueueAction(action);  
    }
})
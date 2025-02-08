({
    createSectionFields: function(fields, component){ //, bodyName
        let items = [];
        for(let index in fields){
            if(fields[index].fieldLabel!==""){
                if(fields[index].fieldType && fields[index].fieldType === 'inputTextArea'){
                    $A.createComponents([
                        ["lightning:layoutItem",{
                            "flexibility":     "auto",
                            "size":             "12",
                            "smallDeviceSize":  "5",
                            "mediumDeviceSize": "5",
                            "largeDeviceSize":  "6",
                            "padding":          "horizontal-small" 
                        }],
                        ["ui:inputTextArea",{
                            "label":    fields[index].fieldLabel,
                            "value":    fields[index].fieldValue,
                            "disabled": true
                        }]
                    ],
                    function(components, status, errorMessage){
                        let layout = components[0];
                        let input = components[1];  
                        layout.set("v.body", input);
                        items.push(layout);
                    });
                }else{
                    $A.createComponents([
                        ["lightning:layoutItem",{
                            "flexibility":     "auto",
                            "size":             "12",
                            "smallDeviceSize":  "5",
                            "mediumDeviceSize": "5",
                            "largeDeviceSize":  "6",
                            "padding":          "horizontal-small" 
                        }],
                        ["ui:inputText",{
                            "label":    fields[index].fieldLabel,
                            "value":    fields[index].fieldValue,
                            "disabled": true
                        }]
                    ],
                    function(components, status, errorMessage){
                        let layout = components[0];
                        let input = components[1];  
                        layout.set("v.body", input);
                        items.push(layout);
                    });
                }
            }
        }

        let elems = component.get('v.body0'); //bodyName
        if(elems){
            elems.push(items);
        }else{
            elems = [];
            elems.push(items);
        }
        component.set("v.body0", elems);
    },

    createSectionComponent: function(component, helper, sectionName){
        helper.createSectionComponentWithObj(component, helper, sectionName, '');
    },

    createSectionComponentWithObj: function(component, helper, sectionName, dataObjects){ //, sectionDataName, bodySectionName
        let sectionData = component.get('v.body0'); //sectionDataName
        let sectionProgr = 1;
        let showPDFSection = component.get('v.showPDFSection');
        let dataObj = '';
        for(let index in sectionData){
            if(dataObjects != ''){
                dataObj = dataObjects[index];
            }
            $A.createComponents([
                ["c:XC_LCP104_RowItem", {
                    "superBody"      : sectionData[index],
                    "title"          : sectionName+" "+sectionProgr,
                    "dataObj"        : JSON.stringify(dataObj),
                    "showPDFSection" : showPDFSection }
                ]],
                function(components, status, errorMessage){
                    let section = component.get('v.sectionBody'); //bodySectionName
                    section.push(components[0]);
                    component.set('v.sectionBody', section); //bodySectionName
                });

            sectionProgr = sectionProgr+1;
        }
    },
	
	showToast : function(component, message, type) {
		console.log('@#@#@#@#@#@ CallToCommodityContract message: '+message);
		component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
    }
})
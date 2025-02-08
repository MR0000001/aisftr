({
    doInit: function (component, event, helper) {
        component.set('v.spinnerControl', true);
        //let action = component.get("c.callCommodityNew");
        //let recordId = component.get("v.recordId");
        //let sobjectType = component.get("v.sobjecttype");
        let bodyName = 'v.body0';
        let bodyContactName = 'v.contactBody';
        let leDataName = 'v.leData';
        let addressDataName = 'v.addressData';
        let billProfDataName = 'v.billProfBody';
        let legalEntityDataName = 'v.legalEntity'
        let podDataName = 'v.podData';
        /*action.setParams({
            'recordId': recordId,
            'sobjectType': sobjectType
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var responseResult = response.getReturnValue();
                if(responseResult.success){
        */
        let responseResult = component.get("v.commodityAccData");
        let resultList = responseResult.recordFields;
        console.log('@@@ resultList ' + JSON.stringify(resultList));
        for (let i in resultList) {
            if (i == 2 || i == 3 || i == 5 || i == 8) {
                var para = document.createElement("p");
                var labelB = document.createElement("b");
                para.appendChild(labelB);
                var node = document.createTextNode(resultList[i].fieldLabel + ": ");
                labelB.appendChild(node);
                var node2 = document.createTextNode(resultList[i].fieldValue);
                para.appendChild(node2);

            }
        }


        for (let index in resultList) {
            if ( ['0', '1', '11', '10'].includes(index) ) {
                $A.createComponents(

                    [
                        ["lightning:layoutItem", {
                            "flexibility": "auto",
                            "size": "10",
                            "smallDeviceSize": "3",
                            "mediumDeviceSize": "3",
                            "largeDeviceSize": "4",
                            "padding": "horizontal-small"
                        }],
                        ["ui:inputText", {
                            "label": resultList[index].fieldLabel,
                            "value": resultList[index].fieldValue,
                            "disabled": true
                        }],
                        ["lightning:button",
                            {
                                "aura:id": "findableAuraId",
                                "name": resultList[index].fieldLabel,
                                //"onclick": component.getReference("c.handlePress"),
                                "label": "Save",
                                "value": resultList[index].fieldValue,
                                "class" : "sparito"
                            }]
                    ],
                    function (components, status, errorMessage) {
                        let layout = components[0];
                        let input = components[1];
                        let button = components[2];
                        //layout.set("v.body0", button);
                        layout.set("v.body", input);
                        let div1 = component.get(bodyName);
                        div1.push(layout);
                        div1.push(button);
                        component.set("v.body0", div1)
                        //component.set(bodyName, div1);

                    }
                );
            } else {
                $A.createComponents(

                    [
                        ["lightning:layoutItem", {
                            "flexibility": "auto",
                            "size": "10",
                            "smallDeviceSize": "3",
                            "mediumDeviceSize": "3",
                            "largeDeviceSize": "4",
                            "padding": "horizontal-small"
                        }],
                        ["ui:inputText", {
                            "label": resultList[index].fieldLabel,
                            "value": resultList[index].fieldValue,
                            "disabled": true
                        }],
                        ["lightning:button",
                            {
                                "aura:id": "findableAuraId",
                                "name": resultList[index].fieldLabel,
                                "onclick": component.getReference("c.handlePress"),
                                "label": "Save",
                                "value": resultList[index].fieldValue
                            }]
                    ],
                    function (components, status, errorMessage) {
                        let layout = components[0];
                        let input = components[1];
                        let button = components[2];
                        //layout.set("v.body0", button);
                        layout.set("v.body", input);
                        let div1 = component.get(bodyName);
                        div1.push(layout);
                        div1.push(button);
                        component.set("v.body0", div1)
                        //component.set(bodyName, div1);

                    }
                );
            }

        }


        let sections = responseResult.sections;
        console.log('@@@@ responseResult : ' + JSON.stringify(responseResult.sections));
        if (sections !== null) {

            //Sezione Contacts
            let contactsSection = sections['Contact'];
            if (contactsSection && contactsSection.objectsRecordFields) {
                for (let indexContact in contactsSection.objectsRecordFields) {
                    helper.createSectionFields(contactsSection.objectsRecordFields[indexContact], component, bodyContactName);

                    //se esistono sottosezioni
                    if (contactsSection.subsectionObjects && contactsSection.subsectionObjects[indexContact] && contactsSection.subsectionObjects[indexContact].length > 0) {
                        //creo per ogni oggetto della sottosezione i suoi campi e li memorizzo in n attributi che popolo dinamicamente
                        for (let subIndex in contactsSection.subsectionObjects[indexContact]) {
                            let newSubFields = contactsSection.subsectionObjects[indexContact][subIndex];
                            if (newSubFields.length > 0 && newSubFields[0].fieldLabel !== "") {
                                helper.createSectionFields(newSubFields, component, leDataName + indexContact);
                            }
                        }
                    }
                }
                //helper.createSectionComponent(component, 'Contact', bodyContactName, 'v.contactSectionBody');
                helper.createNestedSectionsComponent(component, bodyContactName, 'v.contactSectionBody', leDataName, contactsSection, $A.get("$Label.c.XC_CL_Contact"), $A.get("$Label.c.XC_CL_LegalEntity"), true);
            }

            //Sezione BillingProfile
            let billProfSection = sections['BillingProfile'];
            if (billProfSection && billProfSection.objectsRecordFields) {
                for (let indexBill in billProfSection.objectsRecordFields) {
                    helper.createSectionFields(billProfSection.objectsRecordFields[indexBill], component, billProfDataName);
                }
                helper.createSectionComponent(component, 'BillingProfile', billProfDataName, 'v.billProfSectionBody');
            }
            //Sezione LegalEntity
            let leSection = sections['LegalEntity'];
            if (leSection && leSection.objectsRecordFields) {
                for (let indexLE in leSection.objectsRecordFields) {
                    helper.createSectionFields(leSection.objectsRecordFields[indexLE], component, legalEntityDataName);
                }
                helper.createSectionComponent(component, 'LegalEntity', legalEntityDataName, 'v.legalEntity');
            }
            //Sezione Address
            let addressSection = sections['Address'];
            if (addressSection && addressSection.objectsRecordFields) {
                for (let indexAddres in addressSection.objectsRecordFields) {
                    helper.createSectionFields(addressSection.objectsRecordFields[indexAddres], component, addressDataName);

                    //se esistono sottosezioni
                    if (addressSection.subsectionObjects && addressSection.subsectionObjects[indexAddres] && addressSection.subsectionObjects[indexAddres].length > 0) {
                        //creo per ogni oggetto della sottosezione i suoi campi e li memorizzo in n attributi che popolo dinamicamente
                        for (let subIndex in addressSection.subsectionObjects[indexAddres]) {
                            let newSubFields = addressSection.subsectionObjects[indexAddres][subIndex];
                            if (newSubFields.length > 0 && newSubFields[0].fieldLabel !== "") {
                                helper.createSectionFields(newSubFields, component, podDataName + indexAddres);
                            }
                        }
                    }
                }
                //helper.createAddressSectionComponentNEW(component, addressDataName, 'v.addressSectionBody', podDataName, addressSection); //.objectsRecordFields
                helper.createNestedSectionsComponent(component, addressDataName, 'v.addressSectionBody', podDataName, addressSection, $A.get("$Label.c.XC_CL_Address"), $A.get("$Label.c.XC_CL_PointOfService"), true);
            }

            //Sezione Invoices
            /*var invoicesSection = sections['Invoices'];
            if(invoicesSection && invoicesSection.objectsRecordFields){
                for(var index in invoicesSection.objectsRecordFields){
                    helper.createSectionFields(invoicesSection.objectsRecordFields[index], component, invoicesDataName);
                }
                helper.createSectionComponent(component, 'Invoices', invoicesDataName, 'v.invoicesSectionBody');
            }*/

            //Sezione Cases
            var casesSection = sections['Cases'];
            if (casesSection && casesSection.objectsRecordFields) {
                for (var index in casesSection.objectsRecordFields) {
                    helper.createSectionFields(casesSection.objectsRecordFields[index], component, casesDataName);
                }
                helper.createSectionComponent(component, 'Cases', casesDataName, 'v.casesSectionBody');
            }
        }

        /*} else {
            helper.showToast(component, responseResult.resultMessage, 'error');
        } 
    }
});
$A.enqueueAction(action);*/
        component.set('v.spinnerControl', false);
    },

    createSectionComponent: function (component, sectionName, sectionDataName, bodySectionName) {
        let sectionData = component.get(sectionDataName);
        let sectionProgr = 1;
        for (let index in sectionData) {
            $A.createComponents([
                ["c:XC_LCP104_RowItem", {
                    "superBody": sectionData[index],
                    "title": sectionName + " " + sectionProgr
                } //index
                ]],
                function (components, status, errorMessage) {
                    let section = component.get(bodySectionName);
                    section.push(components[0]);
                    component.set(bodySectionName, section);
                });

            sectionProgr = sectionProgr + 1;
        }
    },

    /*createAddressSectionComponent: function(component, sectionDataName, bodySectionName, subsectionDataName, addressSection){
        //'Address', 'POS', 'POD'
        let sectionData = component.get(sectionDataName);
        let subsectionsData = []; //lista di liste di field
        /* tiro fuori dagli attribute di appoggio tutti i dati delle subsections
         * ne è stato creato dinamicamente uno per ogni subsection,
         * con un nome root concatenato a un progressivo
         * /
        for(let index in sectionData){
            let subsection = component.get(subsectionDataName+index);
            subsectionsData.push(subsection);
        }


        for(let index in sectionData){
            let subsections = [];
            let dataValuesStr = JSON.stringify(addressSection.objectsRecordFields[index]);
            let subdataValuesStr = JSON.stringify(addressSection.subsectionObjects[index]);
            //creo le sottosezioni
            for(let subIndex in subsectionsData[index]){
                $A.createComponents([
                    ["c:XC_LCP104_RowItem", { 
                        "superBody"         : subsectionsData[index][subIndex],
                        "title"             : $A.get("$Label.c.XC_CL_PointOfService")+" "+index+"."+subIndex }
                    ]],
                    function(components, status, errorMessage){
                        subsections.push(components[0]);
                });
            }

            let viewSubsection = (subsections.length>0);

            $A.createComponents([
                ["c:XC_LCP104_RowItem", {
                    "superBody"            : sectionData[index],
                    "title"                : $A.get("$Label.c.XC_CL_Address")+" "+index,
                    "stringDataValues"     : dataValuesStr,
                    "stringSubDataValues"  : subdataValuesStr,
                    "showSaveSection"      : true,
                    "subsectionLabel"      : $A.get("$Label.c.XC_CL_PointOfService"),
                    "viewSubsection"       : viewSubsection,
                    "subsectionBody"       : subsections }
                ]],
                function(components, status, errorMessage){
                    let section = component.get(bodySectionName);
                    section.push(components[0]);
                    component.set(bodySectionName, section);
                });
        }
    },*/

    //createAddressSectionComponentNEW: function(component, sectionDataName, bodySectionName, subsectionDataName, addressSection){
    createNestedSectionsComponent: function (component, sectionDataName, bodySectionName, subsectionDataName, mainSection, mainTitle, subTitle, objToSave) {
        let sobjectType = component.get("v.sobjecttype");
        let showSaveSection = (sobjectType === 'Account' && objToSave);
        //'Address', 'POS', 'POD'
        let sectionData = component.get(sectionDataName);
        let subsectionsData = []; //lista di liste di field
        /* tiro fuori dagli attribute di appoggio tutti i dati delle subsections
         * ne è stato creato dinamicamente uno per ogni subsection,
         * con un nome root concatenato a un progressivo
         */
        for (let index in sectionData) {
            let subsection = component.get(subsectionDataName + index);
            subsectionsData.push(subsection);
        }

        let addrProgr = 1;
        let posProgr = 1;
        for (let i in sectionData) {
            //var subsections = [];
            let dataValuesStr = JSON.stringify(mainSection.objectsRecordFields[i]);//addressSection
            let subdataValuesStr = JSON.stringify(mainSection.subsectionObjects[i]);//addressSection

            //inserisco il component sezione padre
            let viewSubsection = true;
            let newComponents = [
                ["c:XC_LCP104_RowItem", {
                    "superBody": sectionData[i],
                    "title": mainTitle + " " + addrProgr, //index //$A.get("$Label.c.XC_CL_Address")
                    "stringDataValues": dataValuesStr,
                    "stringSubDataValues": subdataValuesStr,
                    "showSaveSection": showSaveSection,
                    "subsectionLabel": subTitle,
                    "mainTitle": mainTitle
                } //$A.get("$Label.c.XC_CL_PointOfService")
                    //"viewSubsection"       : viewSubsection,
                    //"subsectionBody"       : subsections }
                ]
            ];

            //inserisco le sottosezioni
            for (let subIndex in subsectionsData[i]) {
                newComponents.push(
                    ["c:XC_LCP104_RowItem", {
                        "superBody": subsectionsData[i][subIndex],
                        "title": subTitle + " " + addrProgr + "." + posProgr
                    } //index - subIndex //$A.get("$Label.c.XC_CL_PointOfService")
                    ]
                );
                posProgr = posProgr + 1;
            }

            $A.createComponents(
                newComponents,
                function (components, status, errorMessage) {
                    let subsections = [];
                    for (let newIndex in components) {
                        if (newIndex !== "0") {
                            subsections.push(components[newIndex]);
                        }
                    }
                    viewSubsection = (subsections.length > 0);
                    components[0].set("v.subsectionBody", subsections);
                    components[0].set("v.viewSubsection", viewSubsection);
                    let section = component.get(bodySectionName);
                    section.push(components[0]);
                    component.set(bodySectionName, section);
                });

            addrProgr = addrProgr + 1;
        }
    },

    handlePress: function (component, event, helper) {
        // Find the button by the aura:id value
        console.log("button: " + component.find("findableAuraId"));
        console.log("button pressed");
        let value = event.getSource().get("v.value");
        let label = event.getSource().get("v.name");
        let accountId = component.get("v.recordId");
        console.log("accountId: " + accountId);
        let action = component.get("c.updateAccount");
        action.setParams({
            'value': value,
            'label': label,
            'accountId': recordId
        });
        console.log("label: " + label);
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                let responseResult = response.getReturnValue();
                if (responseResult.success) {
                    helper.showToast(component, responseResult.resultMessage, 'success');
                } else {
                    helper.showToast(component, responseResult.resultMessage, 'error');
                }
            } else {
                helper.showToast(component, $A.get("$Label.c.XC_CL_ErrorsOccurred"), 'error');
            }
            component.set('v.spinnerControl', false);
        });
        $A.enqueueAction(action);

    },

    createSectionFields: function (fields, component, bodyName) {
        let items = [];
        for (let index in fields) {
            if (fields[index].fieldLabel !== "") {
                $A.createComponents([
                    ["lightning:layoutItem", {
                        "flexibility": "auto",
                        "size": "12",
                        "smallDeviceSize": "5",
                        "mediumDeviceSize": "5",
                        "largeDeviceSize": "6",
                        "padding": "horizontal-small"
                    }],
                    ["ui:inputText", {
                        "label": fields[index].fieldLabel,
                        "value": fields[index].fieldValue,
                        "disabled": true
                    }]
                ],
                    function (components, status, errorMessage) {
                        let layout = components[0];
                        let input = components[1];
                        layout.set("v.body", input);
                        items.push(layout);
                    });
            }
        }

        let elems = component.get(bodyName);
        if (elems) {
            elems.push(items);
        } else {
            elems = [];
            elems.push(items);
        }
        component.set(bodyName, elems);
    },

    /*saveSectionEvent: function(component, event, helper){
        let sobjectType = component.get("v.sobjecttype");
        component.set('v.spinnerControl',true);
        let addressValues = event.getParam("addressValues");
        let posValues = event.getParam("posValues");
        console.debug('addressValues='+addressValues);
        console.debug('posValues='+posValues);
        let recordId = component.get("v.recordId");
        let sobjecttype = component.get("v.sobjecttype");
        
        let action = component.get("c.importAddressFromCommodity");
        action.setParams({
            'inputDataToSave' : { 'recordId' : recordId, 'sobjecttype': sobjecttype},
            'addressValues': JSON.parse(addressValues),
            'posValues' :  JSON.parse(posValues)
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                let responseResult = response.getReturnValue();
                if(responseResult.success){
                    helper.showToast(component, responseResult.resultMessage, 'success');
                }else{
                    helper.showToast(component, responseResult.resultMessage, 'error');
                }
            }else{
                helper.showToast(component, $A.get("$Label.c.XC_CL_ErrorsOccurred"), 'error');
            }
            component.set('v.spinnerControl',false);
        });
        $A.enqueueAction(action);
    },*/

    showToast: function (component, message, type) {
        //var typeValue = type | 'warning';
        console.log('@#@#@#@#@#@ AccountCallToCommodity message: ' + message);
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
    }
})
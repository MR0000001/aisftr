({
    initialize : function(component, event, helper) {
        console.log('TA_LCP228_CatalogtConfiguration >> Helper >> initialize >> Start');
        let b2winResponse = component.get("v.b2winResponse");
        this.manageCart(component, b2winResponse, helper);
        helper.fireToggleSpinnerEvent(component, false);
        console.log('TA_LCP228_CatalogtConfiguration >> Helper >> initialize >> End');
    },

    manageCart : function(component, b2winResponse, helper) {
        console.log('TA_LCP228_CatalogtConfiguration >> Helper >> manageCart >> Start');
        let listOfPicklist = [];
        let listOfAttributesToUpdates = [];
        let bargainingParametersItem = {};
        b2winResponse.cart.forEach(function(cartElement) {
            if(cartElement.fields.eligible == 'Y' && cartElement.fields.LicCategoryName == 'Modalidad contratacion') {
                bargainingParametersItem = cartElement;
                cartElement.listOfAttributes.forEach(function(attribute) {
                    if(attribute.fields.hidden != 'true') {
                        let picklist = {
                                            pfpId : attribute.fields.pfpId,
                                            label : attribute.fields.LicName,
                                            options : [],
                                            value : attribute.fields.DefaultValue
                                        };
                        let attributeToUpdate = {
                                                    pfpId : attribute.fields.pfpId,
                                                    value : attribute.fields.value
                                                };

                        attribute.listOfDomains.forEach(function(domain) {
                            if(domain.fields.eligible == 'Y') {
                                picklist.options.push(domain.fields.value);
                            }
                        });
                        listOfAttributesToUpdates.push(attributeToUpdate);
                        listOfPicklist.push(picklist);
                    }
                });
                bargainingParametersItem.listOfAttributes = listOfAttributesToUpdates;
                component.set("v.bargainingParametersItem", bargainingParametersItem);
            }
        });
        component.set("v.listOfPicklist",listOfPicklist);
        this.manageSelection('TA_LCP199_ButtonSection', 'manageUpsertItems', bargainingParametersItem, true);
        console.log('TA_LCP228_CatalogtConfiguration >> Helper >> manageCart >> End');
    },

    manageCatalogPicklist : function(component, event, helper) {
        console.log('TA_LCP228_CatalogtConfiguration >> Helper >> manageCatalogPicklist >> Start');
        let listOfAttributeToUpdate = [];
        let attributeToUpdate = {
                                    pfpId : event.getSource().get("v.name"),
                                    value : event.getSource().get("v.value")
                                };

        let bargainingParametersItem = component.get("v.bargainingParametersItem");
        bargainingParametersItem.listOfAttributes.forEach(function(attributeToPush) {
            if(attributeToPush.pfpId != attributeToUpdate.pfpId) {
                listOfAttributeToUpdate.push(attributeToPush);
            }
        });

        listOfAttributeToUpdate.push(attributeToUpdate);
        bargainingParametersItem.listOfAttributes = listOfAttributeToUpdate;
        component.set("v.bargainingParametersItem", bargainingParametersItem);
        this.manageSelection('TA_LCP199_ButtonSection', 'manageUpsertItems', bargainingParametersItem, true);
        console.log('TA_LCP228_CatalogtConfiguration >> Helper >> manageCatalogPicklist >> End');
    },

    manageSelection : function(handlerCmpName, actionName, actionParams, showButton) {
        console.log('TA_LCP228_CatalogtConfiguration >> Helper >> manageSelection >> Start');
        let appEvent = $A.get("e.c:TA_LCE226_CartStep");
        appEvent.setParams({
            'handlerCmpName' : handlerCmpName,
            'actionName' : actionName,
            'actionParams' : actionParams,
            'showButton' : showButton
        });
        appEvent.fire();
        console.log('TA_LCP228_CatalogtConfiguration >> Helper >> manageSelection >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP228_CatalogtConfiguration >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP229_CartMainProduct",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP228_CatalogtConfiguration >> Helper >> fireToggleSpinnerEvent >> End');
    }
})
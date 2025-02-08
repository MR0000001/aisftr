({
    initialize : function(component, event, helper) {
        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> initialize >> Start');
        helper.manageCartStepEvt('TA_LCP199_ButtonSection', 'manageRetrieveItemsFromBundleElement', {}, true);
        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> initialize >> End');
    },

    initializeResponse : function(component, event, helper, parameters) {
        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> initializeResponse >> Start');
        component.set('v.b2winResponse', parameters.b2winResponse);
        component.set('v.workOrder', parameters.workOrder);
        
        let b2winResponse = component.get('v.b2winResponse');
        let listOfItems = [];

        b2winResponse.listOfItems.forEach(function(item) {
            listOfItems.push(item);
        });

        let action = component.get("c.initialize_TA_LCP230_CartTechnicalCatalog");
        action.setCallback(this, function(response) {
            console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> initialize >> initializeCallback >> Start');
            if(response.getState() == "SUCCESS") {
                let infoBag = JSON.parse(response.getReturnValue());
                component.set("v.infoBag", infoBag);
                component.set("v.listOfItems", listOfItems);
                this.newGenericProduct(component);
                this.fireToggleSpinnerEvent(component, false);
			} else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
			console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> initialize >> initializeCallback >> End');
		});
        $A.enqueueAction(action);
        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> initializeResponse >> End');
    },

    manageB2WResponse : function(component, event, helper) {
        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> manageB2WResponse >> Start');
        let params = event.getParams();
        console.log('params >>> ' + JSON.stringify(event.getParams()));
        component.set("v.lastestB2winResponse", event.getParams().actionParams.b2winResponse);

        helper[params.actionName](component, event, helper, params.actionParams);

        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> manageB2WResponse >> End');
    },
    
    toggleCardModal : function(component, event, helper) {
        console.log("TA_LCP230_CartTechnicalCatalog >> Helper >> toggleCardModal >> Start");

        let eventSourceName = event.currentTarget.name;
        if(eventSourceName == 'Generic Technical Product' || eventSourceName == 'closeGenericTechnicalProductModal'){
            let showGenericTechnicalProductModal = component.get("v.showGenericTechnicalProductModal");
            component.set("v.showGenericTechnicalProductModal", !showGenericTechnicalProductModal);

        } else {
            let showTechnicalProductModal = component.get("v.showTechnicalProductModal");
            component.set("v.showTechnicalProductModal", !showTechnicalProductModal);
            if(eventSourceName == 'Technical Product') {
                component.set("v.retrievedProduct2List", component.get("v.infoBag.technicalProductsList"));
                component.set("v.selectedProduct2List", component.get("v.infoBag.selectedTechnicalProductsList"));

            } else if(eventSourceName == 'Technical Work') {
                component.set("v.retrievedProduct2List", component.get("v.infoBag.technicalWorkList"));
                component.set("v.selectedProduct2List", component.get("v.infoBag.selectedTechnicalWorkList"));
            }

            if(component.get("v.selectedProduct2List").length > 0) {
                component.set("v.noSelectedProduct", false);
                component.set("v.disableDoneButton", false);
            } else {
                component.set("v.noSelectedProduct", true);
                component.set("v.disableDoneButton", true);
            }
        }

        if(component.get("v.showTechnicalProductModal") || component.get("v.showGenericTechnicalProductModal")){
            component.set("v.modalHeaderTitle", eventSourceName);
        }
        
        //component.set("v.filteredRetrievedProduct2List", component.get("v.retrievedProduct2List"));
        console.log("showGenericTechnicalProductModal >>> ", component.get("v.showGenericTechnicalProductModal"));
        component.set("v.currentTechType", eventSourceName);

		console.log("TA_LCP230_CartTechnicalCatalog >> Helper >> toggleCardModal >> Finish");
    },

    toggleCatalogModal : function(component, event, helper) {
        console.log("TA_LCP230_CartTechnicalCatalog >> Helper >> toggleCatalogModal >> Start");
        let showCatalogModal = component.get("v.showCatalogModal");
        component.set("v.showCatalogModal", !showCatalogModal);
		console.log("TA_LCP230_CartTechnicalCatalog >> Helper >> toggleCatalogModal >> Finish");
    },

    toggleGenericTechnicalCatalog : function(component, event, helper) {
        console.log("TA_LCP230_CartTechnicalCatalog >> Helper >> toggleGenericTechnicalCatalog >> Start");
        let showGenericTechnicalCatalog = component.get("v.showGenericTechnicalCatalog");
        component.set("v.showGenericTechnicalCatalog", !showGenericTechnicalCatalog);
		console.log("TA_LCP230_CartTechnicalCatalog >> Helper >> toggleGenericTechnicalCatalog >> Finish");
    },

    decrementQuantity : function(component, event, helper) {
        console.log("TA_LCP230_CartTechnicalCatalog >> Helper >> decrementQuantity >> Start");
        let currentTechType = component.get("v.currentTechType");
        let infoBag = component.get("v.infoBag");
        let productId = event.currentTarget.id;
        let currentProduct;
        console.log('productId >>> ' + productId);

        let selectedProduct2List = component.get("v.selectedProduct2List");
        selectedProduct2List.forEach(function(product) {
            if(product.productId == productId && product.quantity > 1){
               
                let unitPrice = parseFloat(product.unitPrice);
                let newQuantity = parseInt(product.quantity);
                newQuantity --;
                product.quantity = newQuantity;
                currentProduct = product;
            
                if(currentTechType == 'Technical Product'){
                    let selectedTechnicalProductTotalAmount = parseFloat(infoBag.selectedTechnicalProductTotalAmount);
                    infoBag.selectedTechnicalProductTotalAmount = (selectedTechnicalProductTotalAmount - unitPrice).toFixed(2);
                    
                } else if (currentTechType == 'Technical Work'){
                    let selectedTechnicalWorkTotalAmount = parseFloat(infoBag.selectedTechnicalWorkTotalAmount);
                    infoBag.selectedTechnicalWorkTotalAmount = (selectedTechnicalWorkTotalAmount - unitPrice).toFixed(2);
                }
            }
        });

        component.set("v.infoBag", infoBag);
        component.set("v.selectedProduct2List", selectedProduct2List);

		console.log("TA_LCP230_CartTechnicalCatalog >> Helper >> decrementQuantity >> Finish");
    },

    incrementQuantity : function(component, event, helper) {
        console.log("TA_LCP230_CartTechnicalCatalog >> Helper >> incrementQuantity >> Start");
        let currentTechType = component.get("v.currentTechType");
        let infoBag = component.get("v.infoBag");
        let productId = event.currentTarget.id;
        let currentProduct;
        console.log('productId >>> ' + productId);

        let selectedProduct2List = component.get("v.selectedProduct2List");
        selectedProduct2List.forEach(function(product) {
            if(product.productId == productId){
                let unitPrice = parseFloat(product.unitPrice);
                let newQuantity = parseInt(product.quantity);
                newQuantity ++;
                product.quantity = newQuantity;
                currentProduct = product;

                if(currentTechType == 'Technical Product'){
                    let selectedTechnicalProductTotalAmount = parseFloat(infoBag.selectedTechnicalProductTotalAmount);
                    infoBag.selectedTechnicalProductTotalAmount = (selectedTechnicalProductTotalAmount + unitPrice).toFixed(2);
                    
                } else if (currentTechType == 'Technical Work'){
                    let selectedTechnicalWorkTotalAmount = parseFloat(infoBag.selectedTechnicalWorkTotalAmount);
                    infoBag.selectedTechnicalWorkTotalAmount = (selectedTechnicalWorkTotalAmount + unitPrice).toFixed(2);
                }
            }
        });

        component.set("v.infoBag", infoBag);
        component.set("v.selectedProduct2List", selectedProduct2List);
        
        console.log("TA_LCP230_CartTechnicalCatalog >> Helper >> incrementQuantity >> Finish");
    },

    addProduct : function(component, event, helper) {
        console.log("TA_LCP230_CartTechnicalCatalog >> Helper >> addProduct >> Start");

        let infoBag = component.get("v.infoBag");
        let currentTechType = component.get("v.currentTechType");
        let retrievedProduct2List = component.get("v.retrievedProduct2List");
        let selectedProduct2List = component.get("v.selectedProduct2List");
        let productId = event.currentTarget.id;
        let currentProduct;
        
        for(let i = 0; i < retrievedProduct2List.length; i++){
            if(retrievedProduct2List[i].productId == productId){
                let unitPrice = parseFloat(retrievedProduct2List[i].unitPrice);
                retrievedProduct2List[i].quantity ++;
                currentProduct = retrievedProduct2List[i];

                if(currentTechType == 'Technical Product'){
                    
                    selectedProduct2List.push(retrievedProduct2List[i]);
                    selectedProduct2List.sort((firstElementToSort, secondElementToSort) => (firstElementToSort.name > secondElementToSort.name) ? 1 : -1);
                    infoBag.selectedTechnicalProductsList.push(retrievedProduct2List[i]);

                    let selectedTechnicalProductTotalAmount = parseFloat(infoBag.selectedTechnicalProductTotalAmount);
                    infoBag.selectedTechnicalProductTotalAmount = (selectedTechnicalProductTotalAmount + unitPrice).toFixed(2);

                    retrievedProduct2List.splice(i, 1);
                    infoBag.technicalProductsList = retrievedProduct2List;

                } else if (currentTechType == 'Technical Work'){

                    selectedProduct2List.push(retrievedProduct2List[i]);
                    infoBag.selectedTechnicalWorkList.push(retrievedProduct2List[i]);

                    let selectedTechnicalWorkTotalAmount = parseFloat(infoBag.selectedTechnicalWorkTotalAmount);
                    infoBag.selectedTechnicalWorkTotalAmount = (selectedTechnicalWorkTotalAmount + unitPrice).toFixed(2);

                    retrievedProduct2List.splice(i, 1);
                    infoBag.technicalWorkList = retrievedProduct2List;
                }

                break;
            }
        }

        component.set("v.infoBag", infoBag);
        component.set("v.retrievedProduct2List", retrievedProduct2List);
        component.set("v.selectedProduct2List", selectedProduct2List);
        component.set("v.noSelectedProduct", false);
        component.set("v.showCatalogModal", false);
        component.set("v.disableDoneButton", false);

		console.log("TA_LCP230_CartTechnicalCatalog >> Helper >> addProduct >> Finish");
    },

    removeProduct : function(component, event, helper) {
        console.log("TA_LCP230_CartTechnicalCatalog >> Helper >> removeProduct >> Start");

        let infoBag = component.get("v.infoBag");
        let currentTechType = component.get("v.currentTechType");
        let retrievedProduct2List = component.get("v.retrievedProduct2List");
        let selectedProduct2List = component.get("v.selectedProduct2List");
        let productId = event.currentTarget.id;
        let currentRemovedProductName;

        for(let i = 0; i < selectedProduct2List.length; i++){
            if(selectedProduct2List[i].productId == productId){
                currentRemovedProductName = selectedProduct2List[i].name;
                console.log('@@>> currentRemovedProductName ' + currentRemovedProductName);
                let unitPrice = parseFloat(selectedProduct2List[i].unitPrice);
                let quantity = selectedProduct2List[i].quantity;

                if(currentTechType == 'Technical Product'){
                    let selectedTechnicalProductTotalAmount = parseFloat(infoBag.selectedTechnicalProductTotalAmount);
                    infoBag.selectedTechnicalProductTotalAmount = (selectedTechnicalProductTotalAmount - (unitPrice * quantity)).toFixed(2);

                    retrievedProduct2List.push(selectedProduct2List[i]);
                    retrievedProduct2List.sort((firstElementToSort, secondElementToSort) => (firstElementToSort.name > secondElementToSort.name) ? 1 : -1);
                    selectedProduct2List.splice(i, 1);
                    infoBag.selectedTechnicalProductsList = selectedProduct2List;
                    infoBag.technicalProductsList = retrievedProduct2List;

                    if(infoBag.selectedTechnicalProductsList.length == 0){
                        component.set("v.noSelectedProduct", true);
                        component.set("v.disableDoneButton", true);
                    }

                } else if (currentTechType == 'Technical Work'){
                    let selectedTechnicalWorkTotalAmount = parseFloat(infoBag.selectedTechnicalWorkTotalAmount);
                    infoBag.selectedTechnicalWorkTotalAmount = (selectedTechnicalWorkTotalAmount - (unitPrice * quantity)).toFixed(2);

                    retrievedProduct2List.push(selectedProduct2List[i]);
                    retrievedProduct2List.sort((firstElementToSort, secondElementToSort) => (firstElementToSort.name > secondElementToSort.name) ? 1 : -1);
                    selectedProduct2List.splice(i, 1);
                    infoBag.selectedTechnicalWorkList = selectedProduct2List;
                    infoBag.technicalWorkList = retrievedProduct2List;

                    if(infoBag.selectedTechnicalWorkList.length == 0){
                        component.set("v.noSelectedProduct", true);
                        component.set("v.disableDoneButton", true);
                    }
                }

                for(let j = 0; j < retrievedProduct2List.length; j++){
                    if(retrievedProduct2List[j].productId == productId){
                        retrievedProduct2List[j].quantity = 0;
                        break;
                    }
                }

                break;
            }
        }

        let b2winResponse = component.get('v.lastestB2winResponse');
        console.log('@@>> b2winResponse >>> ' + JSON.stringify(b2winResponse));
        console.log('@@>> productId >>> ' + JSON.stringify(productId));
        let itemToRemove = {};
        let itemInCart = false;

        b2winResponse.cart.forEach(function(cartItem) {
            console.log('@@>> cartItem >>> ' + JSON.stringify(cartItem));
            cartItem.listOfAttributes.forEach(function(attribute) {
                if(attribute.fields.LicName == 'Descripcion Referencia' && attribute.fields.value == currentRemovedProductName){
                    itemToRemove = cartItem;
                    console.log('@@>> itemToRemove >>> ' + JSON.stringify(itemToRemove));
                    itemInCart = true;
                }
            });
        });

        console.log('@@>> itemInCart >>> ' + JSON.stringify(itemInCart));

        if(itemInCart){
            helper.manageCartStepEvt('TA_LCP226_CartContainer', 'manageRemoveFromCart', itemToRemove);
        }
        
        component.set("v.retrievedProduct2List", retrievedProduct2List);
        component.set("v.infoBag", infoBag);
        component.set("v.selectedProduct2List", selectedProduct2List);
        helper.fireToggleSpinnerEvent(component, false);

		console.log("TA_LCP230_CartTechnicalCatalog >> Helper >> removeProduct >> Finish");
    },

    searchProduct : function(component, event, helper) {
        console.log("TA_LCP230_CartTechnicalCatalog >> Helper >> searchProduct >> Start");
        let searchInput = event.getSource().get("v.value");
        let filteredRetrievedProduct2List = component.get("v.retrievedProduct2List");

        if(searchInput){
            for(let i = 0; i < filteredRetrievedProduct2List.length; i++){
                if(!filteredRetrievedProduct2List[i].name.startsWith(searchInput)){
                    filteredRetrievedProduct2List.splice(i, 1);
                }
            }
            component.set("v.filteredRetrievedProduct2List", filteredRetrievedProduct2List);
        } else {
            component.set("v.filteredRetrievedProduct2List", component.get("v.retrievedProduct2List"));
        }
        
		console.log("TA_LCP230_CartTechnicalCatalog >> Helper >> searchProduct >> Finish");
    },

    decrementGenericTechnicalProductQuantity : function(component, event, helper) {
        console.log("TA_LCP230_CartTechnicalCatalog >> Helper >> decrementGenericTechnicalProduct >> Start");
        let genericTechnicalProductToSendQuantity = component.get("v.genericTechnicalProductToSend.quantity");
        if(genericTechnicalProductToSendQuantity > 0){
            genericTechnicalProductToSendQuantity --;
        }

        component.set("v.genericTechnicalProductToSend.quantity", genericTechnicalProductToSendQuantity);
		console.log("TA_LCP230_CartTechnicalCatalog >> Helper >> decrementGenericTechnicalProduct >> Finish");
    },

    incrementGenericTechnicalProductQuantity : function(component, event, helper) {
        console.log("TA_LCP230_CartTechnicalCatalog >> Helper >> incrementGenericTechnicalProductQuantity >> Start");
        let genericTechnicalProductToSendQuantity = component.get("v.genericTechnicalProductToSend.quantity");
        genericTechnicalProductToSendQuantity ++;
        
        component.set("v.genericTechnicalProductToSend.quantity", genericTechnicalProductToSendQuantity);
		console.log("TA_LCP230_CartTechnicalCatalog >> Helper >> incrementGenericTechnicalProductQuantity >> Finish");
    },

    addGenericTechnicalProductToCart : function(component, event, helper) {
        console.log("TA_LCP230_CartTechnicalCatalog >> Helper >> addGenericTechnicalProductToCart >> Start");
        let infoBag = component.get("v.infoBag");
        let genericTechnicalProductTotalAmount = parseFloat(infoBag.genericTechnicalProductTotalAmount);
        let genericTechnicalProductToSend = component.get("v.genericTechnicalProductToSend");

        genericTechnicalProductTotalAmount = (genericTechnicalProductTotalAmount + (parseFloat(genericTechnicalProductToSend.unitPrice) * genericTechnicalProductToSend.quantity)).toFixed(2);
        
        component.set("v.infoBag.genericTechnicalProductTotalAmount", genericTechnicalProductTotalAmount);

        this.toggleGenericTechnicalCatalog(component, event, helper);
        component.set("v.showGenericTechnicalProductModal", false);
        this.newGenericProduct(component);
		console.log("TA_LCP230_CartTechnicalCatalog >> Helper >> addGenericTechnicalProductToCart >> Finish");
    },

    newGenericProduct : function(component){
        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> newGenericProduct >> Start');
        let genericTechnicalProductToSend = {};
        genericTechnicalProductToSend.quantity = parseInt(0);
        genericTechnicalProductToSend.description = '';
        genericTechnicalProductToSend.unitPrice = parseFloat(0.00);
        genericTechnicalProductToSend.reference = '';
        component.set("v.genericTechnicalProductToSend", genericTechnicalProductToSend);
        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> newGenericProduct >> End');
    },

    addSelectedProductsToCart : function(component, event, helper, firstTimeCalled){
        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> addSelectedProductsToCart >> Start');

        helper.fireToggleSpinnerEvent(component, true);

        let currentTechType = component.get("v.currentTechType");
        let selectedProduct2List = component.get("v.selectedProduct2List");
        console.log("@@>> selectedProduct2List >>> ", JSON.stringify(selectedProduct2List));

        let currentProduct = selectedProduct2List[component.get("v.productsToSend")];
        component.set("v.currentProduct", currentProduct);
        console.log("@@>> currentProduct >>>>>>>>> " + JSON.stringify(currentProduct));
        console.log('Ale:  addSelectedProductsToCart');
        component.set("v.saveConfigurationAlreadyCalled",false);
        helper.sendCartEvent(component, currentTechType, 'manageAddToCart', currentProduct, firstTimeCalled);
        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> addSelectedProductsToCart >> End');
    },

    sendCartEvent : function(component, currentTechType, action, currentProduct, firstTimeCalled){
        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> sendCartEvent >> Start');

        let itemToSend = {};
        
        let listOfItems = component.get("v.listOfItems");
        listOfItems.forEach(function(item) {
            if(item.fields.LicProductName == currentTechType){
                item.fields.bundleInCart = "true";
                if(firstTimeCalled){
                    item.fields.bundleInCart = "false";
                }
                console.log("@@>> currentProduct.productId >>> " + currentProduct.productId);
                console.log("@@>> currentProduct.unitPrice >>> " + currentProduct.unitPrice);
                
                item.fields.configurationOneTimeFee = Number(currentProduct.unitPrice);
				item.fields.baseonetimefee = Number(Number(currentProduct.unitPrice) * Number(currentProduct.quantity));
				item.fields.startingbaseonetimefee = Number(currentProduct.unitPrice);
				item.fields.onetimefeediscounted = Number(currentProduct.unitPrice);
				item.fields.onetimefeeov = Number(currentProduct.unitPrice);
				item.fields.netonetimefee = Number(currentProduct.unitPrice);
				item.fields.ReferenceOneTimeFee = Number(currentProduct.unitPrice);
				item.fields.totalonetimefeeov = Number(currentProduct.unitPrice);
				item.fields.totalbaseonetimefee = Number(currentProduct.unitPrice);
				item.fields.totalonetimefeediscounted = Number(currentProduct.unitPrice);
                item.fields.qty = Number(currentProduct.quantity);
                itemToSend = item;
            }
        });

        console.log('itemToSend >>> ' + JSON.stringify(itemToSend));
        let sendCartEvent = $A.get("e.c:TA_LCE226_CartStep");

        sendCartEvent.setParams({
            'handlerCmpName' : 'TA_LCP226_CartContainer',
            'actionName' : action,
            'actionParams' : itemToSend,
            'currentProductId' : currentProduct.productId
        });
        sendCartEvent.fire();

        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> sendCartEvent >> End');
    },
    
    addRemoveFromCartResponse : function(component, event, helper){
        console.log('Ale:  addRemoveFromCartResponse');
        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> receiveAddRemoveCartResponse >> Start');
        console.log('event.getParams(); >>> ' + JSON.stringify(event.getParams()));

        let cartResponse = event.getParam('actionParams').b2winResponse;
        let currentTechType = component.get("v.currentTechType");
        let currentProduct = component.get("v.currentProduct");
        console.log("@@>> cartResponse >>> " + JSON.stringify(cartResponse));
        component.set("v.cartResponse", cartResponse);
            
        for(let i = 0; i < cartResponse.cart.length; i++){
            console.log("cartResponse.cart[i].fields.productname >>> " + JSON.stringify(cartResponse.cart[i].fields.productname));
            if(cartResponse.cart[i].fields.productname == currentTechType && cartResponse.cart[i].listOfAttributes[0].fields.value == ''){
                
                //cartResponse.cart[i].fields.qty = currentProduct.quantity;
                cartResponse.cart[i].fields.configurationOneTimeFee = Number(currentProduct.unitPrice);
				cartResponse.cart[i].fields.baseonetimefee = Number(Number(currentProduct.unitPrice) * Number(currentProduct.quantity));
				cartResponse.cart[i].fields.startingbaseonetimefee = Number(currentProduct.unitPrice);
				cartResponse.cart[i].fields.onetimefeediscounted = Number(currentProduct.unitPrice);
				cartResponse.cart[i].fields.onetimefeeov = Number(currentProduct.unitPrice);
				cartResponse.cart[i].fields.netonetimefee = Number(currentProduct.unitPrice);
				cartResponse.cart[i].fields.ReferenceOneTimeFee = Number(currentProduct.unitPrice);
				cartResponse.cart[i].fields.totalonetimefeeov = Number(currentProduct.unitPrice);
				cartResponse.cart[i].fields.totalbaseonetimefee = Number(currentProduct.unitPrice);
				cartResponse.cart[i].fields.totalonetimefeediscounted = Number(currentProduct.unitPrice);
                cartResponse.cart[i].fields.qty = Number(currentProduct.quantity);

                console.log("cartResponse.cart[i].fields.qty >>> " + JSON.stringify(cartResponse.cart[i].fields.qty));
                console.log("cartResponse.cart[i].fields.catalogId >>> " + JSON.stringify(cartResponse.cart[i].fields.catalogId));
                console.log("cartResponse.cart[i].fields.categoryId; >>> " + JSON.stringify(cartResponse.cart[i].fields.categoryId));
                console.log("cartResponse.cart[i].fields.itemCod >>> " + JSON.stringify(cartResponse.cart[i].fields.itemCod));
                console.log("cartResponse.cart[i].fields.productId >>> " + JSON.stringify(cartResponse.cart[i].fields.productId));
                console.log("cartResponse.cart[i].fields.catalogId >>> " + JSON.stringify(cartResponse.cart[i].fields.catalogId));

                let attributes = [];

                cartResponse.cart[i].listOfAttributes.forEach(function(attribute) {

                    let att = {};
                    att.fields = {};
                    
                    if(currentTechType == 'Technical Product' || currentTechType == 'Technical Work'){
                        if(attribute.fields.LicName == 'Descripcion'){
                            att.fields.pfpId = attribute.fields.pfpId;
                            att.fields.value = currentProduct.name;
                        } else if(attribute.fields.LicName == 'Referencia'){
                            att.fields.pfpId = attribute.fields.pfpId;
                            att.fields.value = currentProduct.productCode;
                        } else if(attribute.fields.LicName == 'Precio Endesa'){
                            att.fields.pfpId = attribute.fields.pfpId;
                            att.fields.value = currentProduct.unitPrice;
                        } else if(attribute.fields.LicName == 'Precio Penalizacion'){
                            att.fields.pfpId = attribute.fields.pfpId;
                            att.fields.value = currentProduct.precioPenalizacion;
                        } else if(attribute.fields.LicName == 'Asset Repaired Subtype'){
                            att.fields.pfpId = attribute.fields.pfpId;
                            att.fields.value = currentProduct.assetRepairedSubtype;
                        } else if(attribute.fields.LicName == ' Asset Repaired Warranty End Date'){
                            att.fields.pfpId = attribute.fields.pfpId;
                            att.fields.value = '';
                        } else if(attribute.fields.LicName == 'Descripcion Referencia'){
                            att.fields.pfpId = attribute.fields.pfpId;
                            att.fields.value = currentProduct.name;
                        } else if(attribute.fields.LicName == 'Modelo'){
                            att.fields.pfpId = attribute.fields.pfpId;
                            att.fields.value = currentProduct.modelo;
                        } else if(attribute.fields.LicName == 'Familia'){
                            att.fields.pfpId = attribute.fields.pfpId;
                            att.fields.value = currentProduct.familia;
                        } else if(attribute.fields.LicName == 'Fabricante'){
                            att.fields.pfpId = attribute.fields.pfpId;
                            att.fields.value = currentProduct.fabricante;
                        } else if(attribute.fields.LicName == 'Producto'){
                            att.fields.pfpId = attribute.fields.pfpId;
                            att.fields.value = currentProduct.producto;
                        } else if(attribute.fields.LicName == 'Partner Reimbursement'){
                            att.fields.pfpId = attribute.fields.pfpId;
                            att.fields.value = currentProduct.partnerReimbursement;
                        }
                    } else if (currentTechType == 'Generic Technical Product'){
                        let genericTechnicalProductToSend = component.get("v.genericTechnicalProductToSend");
                        if(attribute.fields.LicName == 'PartnerReimbursment'){
                            att.fields.pfpId = attribute.fields.pfpId;
                            att.fields.value = genericTechnicalProductToSend.unitPrice;
                        } else if(attribute.fields.LicName == 'Referencia'){
                            att.fields.pfpId = attribute.fields.pfpId;
                            att.fields.value = genericTechnicalProductToSend.reference;
                        } else if(attribute.fields.LicName == 'Generic Technical Product Description'){
                            att.fields.pfpId = attribute.fields.pfpId;
                            att.fields.value = genericTechnicalProductToSend.description;
                        } else if(attribute.fields.LicName == 'PrecioEndesa'){
                            att.fields.pfpId = attribute.fields.pfpId;
                            att.fields.value = genericTechnicalProductToSend.unitPrice;
                        }
                    }
                    attributes.push(att);
                });

                cartResponse.cart[i].listOfAttributes = attributes;                
                console.log("@@>> cartResponse.cart[i] >>> " + JSON.stringify(cartResponse.cart[i]));

                helper.sendUpsertItemsEvt(cartResponse.cart[i]);
                break;
            }
        }

        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> receiveAddRemoveCartResponse >> End');
    },

    sendUpsertItemsEvt : function(actionParams){
        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> sendUpsertItemsEvt >> Start');
        let fireSendUpsertItemsEvt = $A.get("e.c:TA_LCE226_CartStep");
        console.log('Ale:  sendUpsertItemsEvt');
        fireSendUpsertItemsEvt.setParams({
            'handlerCmpName' : 'TA_LCP226_CartContainer',
            'actionName' : 'manageUpsertItems',
            'actionParams' : actionParams
        });
        fireSendUpsertItemsEvt.fire();
        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> sendUpsertItemsEvt >> End');
    },
    
    manageUpsertItemsResponse : function(component, event, helper){
        console.log('Ale:  manageUpsertItemsResponse');
        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> manageUpsertItemsResponse >> Start');
        console.log('event.getParams(); >>> ' + JSON.stringify(event.getParams()));

        let cartResponse = event.getParam('actionParams').b2winResponse;
        helper.sendSaveConfigurationEvt(cartResponse);

        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> manageUpsertItemsResponse >> End');
    },

    sendSaveConfigurationEvt : function(actionParams){
        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> sendSaveConfigurationEvt >> Start');
        let fireSendSaveConfigurationEvt = $A.get("e.c:TA_LCE226_CartStep");
        console.log('Ale:  sendSaveConfigurationEvt');
        fireSendSaveConfigurationEvt.setParams({
            'handlerCmpName' : 'TA_LCP226_CartContainer',
            'actionName' : 'manageSaveConfiguration',
            'actionParams' : actionParams
        });
        fireSendSaveConfigurationEvt.fire();
        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> sendSaveConfigurationEvt >> End');
    },
    
    manageSaveConfigurationResponse : function(component, event, helper){
        console.log('saveConfigurationAlreadyCalled: ',component.get("v.saveConfigurationAlreadyCalled"));
        if(component.get("v.saveConfigurationAlreadyCalled") == false){
            component.set("v.saveConfigurationAlreadyCalled",true);
            return;
        }

        console.log('Ale:  manageSaveConfigurationResponse');
        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> manageSaveConfigurationResponse >> Start');
        console.log('component.get("v.selectedProduct2List").length >>> ',component.get("v.selectedProduct2List").length);
        console.log('component.get("v.productsToSend") >>> ', component.get("v.productsToSend"));
        let productsToSend = component.get("v.productsToSend");

        if(component.get("v.selectedProduct2List").length > productsToSend){
            let incrementedProductsToSend = Number(productsToSend + 1);
            if(component.get("v.selectedProduct2List").length == incrementedProductsToSend){
                component.set("v.showTechnicalProductModal", false);
                helper.fireToggleSpinnerEvent(component, false);
            } else {
                component.set("v.productsToSend", incrementedProductsToSend);
                console.log('component.get("v.productsToSend") >>> ', component.get("v.productsToSend"));

                let listOfItems = [];
                let b2winResponse = event.getParam('actionParams').b2winResponse;
                console.log('b2winResponse >>> ', JSON.stringify(b2winResponse));
                
                b2winResponse.listOfItems.forEach(function(item) {
                            item.fields.bundleInCart = "true";
                            listOfItems.push(item);
                        });
                component.set("v.listOfItems", listOfItems);

                helper.addSelectedProductsToCart(component,event,helper, false);
            }
        }
        else{
            component.set("v.showTechnicalProductModal", false);
            helper.fireToggleSpinnerEvent(component, false);
        }

        helper.refreshCartEvt(event.getParam('actionParams'));

        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> manageUpsertItemsResponse >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP230_CartTechnicalCatalog >> fireToggleSpinnerEvent >> Start');

        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP230_CartTechnicalCatalog",
            "toggleSpinner"   : toggleSpinner
        });

        toggleSpinnerEvent.fire();
        console.log('TA_LCP230_CartTechnicalCatalog >> fireToggleSpinnerEvent >> End');
    },

    manageCartStepEvt : function(handlerCmpName, actionName, actionParams, showButton) {
        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> manageCartStepEvt >> Start');
        let appEvent = $A.get("e.c:TA_LCE226_CartStep");
        appEvent.setParams({
            'handlerCmpName' : handlerCmpName,
            'actionName' : actionName,
            'actionParams' : actionParams,
            'showButton' : showButton
        });
        appEvent.fire();
        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> manageCartStepEvt >> End');
    },

    refreshCartEvt : function(responseCart) {
        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> refreshCartEvt >> Start');
        let fireRefreshEvt = $A.get("e.c:TA_LCE224_Refresh");
        fireRefreshEvt.setParams({
            'action' : 'refresh-cart',
            'params' : responseCart
        });
        fireRefreshEvt.fire();
        console.log('TA_LCP230_CartTechnicalCatalog >> Helper >> refreshCartEvt >> End');
    }
})
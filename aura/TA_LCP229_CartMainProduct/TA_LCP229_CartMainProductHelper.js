({
    initialize : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Helper >> initialize >> Start');
        //helper.manageCartStepEvt('TA_LCP199_ButtonSection', null, {});
        console.log('TA_LCP229_CartMainProduct >> Helper >> initialize >> End');
    },

    initializeResponse : function(component, event, helper, parameters) {
        console.log('TA_LCP229_CartMainProduct >> Helper >> initializeResponse >> Start');
        component.set('v.b2winResponse', parameters.b2winResponse);
        component.set('v.b2winCurrentBundleElement', parameters.b2winCurrentBundleElement);
        component.set('v.workOrder', parameters.workOrder);
        component.set('v.isBundle', parameters.isBundle);
        helper.createMainProductList(component, event, helper);
        console.log('TA_LCP229_CartMainProduct >> Helper >> initializeResponse >> End');
    },

    createMainProductList : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Helper >> createMainProductList >> Start');
        let b2winResponse = component.get('v.b2winResponse');
        let b2winResponseListOfItems = [];
        let filterBrandValueList = ['All'];
        let filterAvailabilityValueList = ['All','No','Yes'];
        let productsSelectedIds = [];

        b2winResponse.listOfItems.forEach(function(item) {
            //START FIX [#20210303AL] - andrea.liverani@webresults.it
            //if(item.fields.eligible == 'Y') {
            if(item.fields.visible == 'true') {
            //if(item.fields.eligible == 'Y' && item.fields.visible == 'true') {
            //END FIX [#20210303AL] - andrea.liverani@webresults.it
                item.TA_availabilityLocalWarehouse = 0;

                item.listOfAttributes.forEach(function(attribute) {
                    //START FIX [#20210303AL] - Fix delivery
                    //if(attribute.fields.name == 'Delivery Date') {
                    if(attribute.fields.LicName == 'Estimated Delivery Date') {
                    //END FIX [#20210303AL] - Fix delivery
                        item.TA_deliveryDate = attribute.fields.value;
                    }
                });

                item.listOfCharacteristics.forEach(function(characteristics) {
                    if(characteristics.fields.LicName == 'Power') {
                        item.TA_power = characteristics.fields.value;
                    }
                    if(characteristics.fields.LicName == 'Technology') {
                        item.TA_technology = characteristics.fields.value;
                    }
                });

                if(!filterBrandValueList.includes(item.fields.XC_Brand)) {
                    filterBrandValueList.push(item.fields.XC_Brand);
                }

                b2winResponse.cart.forEach(function(cartItem) {
                    if(item.fields.id == cartItem.id) {
                        productsSelectedIds.push(item.fields.id);
                    }
                });

                b2winResponseListOfItems.push(item);
            }
        });

        component.set('v.productsSelectedIds', productsSelectedIds);
        component.set('v.filterBrandValueList', filterBrandValueList);
        component.set('v.filterAvailabilityValueList', filterAvailabilityValueList);
        component.set('v.listOfItems', b2winResponseListOfItems);
        component.set('v.listOfFilteredItems', b2winResponseListOfItems);

        helper.paginateListOfItems(component, event, helper);
        helper.retriveApexInfo(component, event, helper);
        console.log('TA_LCP229_CartMainProduct >> Helper >> createMainProductList >> End');
    },

    manageB2WResponse : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Helper >> manageB2WResponse >> Start');
        let params = event.getParams();
        helper[params.actionName](component, event, helper, params.actionParams);
        console.log('TA_LCP229_CartMainProduct >> Helper >> manageB2WResponse >> End');
    },

    paginateListOfItems : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Helper >> paginateListOfItems >> Start');
        let listOfFilteredItems = component.get('v.listOfFilteredItems');
        let numberOfItemsPerPage = component.get('v.numberOfItemsPerPage');

        let currentPage = 0;
        let paginatedListOfItems = {};
        paginatedListOfItems[currentPage] = [];
        listOfFilteredItems.forEach(function(item) {
            if(paginatedListOfItems[currentPage].length >= numberOfItemsPerPage) {
                currentPage++;
                paginatedListOfItems[currentPage] = [];
            }
            paginatedListOfItems[currentPage].push(item);
        });

        component.set('v.paginatedListOfItems', paginatedListOfItems);
        component.set('v.currentPageNumber', 0);
        component.set('v.totalPageNumber', Object.keys(paginatedListOfItems).length);
        console.log('TA_LCP229_CartMainProduct >> Helper >> paginateListOfItems >> End');
    },

    retriveApexInfo : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Helper >> retriveApexInfo >> Start');
        let paginatedListOfItems = component.get('v.paginatedListOfItems');
        let currentPageNumber = component.get('v.currentPageNumber');
        let listOfItems = paginatedListOfItems[currentPageNumber];

        let action = component.get('c.initialize_TA_LCP229_CartMainProduct');
        action.setParam('listOfItemsSerialized', JSON.stringify(listOfItems));
        action.setCallback(this, function(response) {
            console.log('TA_LCP229_CartMainProduct >> Helper >> retriveApexInfoCallback >> Start');
            if(response.getState() == "SUCCESS") {
                let itemsToShow = JSON.parse(response.getReturnValue().listOfItems); 
                itemsToShow.forEach(function(item) {
                    if(item.fields.productname.length > 32) item.TA_productnametruncated = item.fields.productname.substring(0, 31) + '..';

                    if(item.fields.ReferenceOneTimeFee != null && item.fields.ReferenceOneTimeFee > item.fields.baseonetimefee) {
                        item.fields.priceToDiscount = item.fields.ReferenceOneTimeFee;
                    } else if(item.fields.Orig_OneTimeFee__c != null && item.fields.Orig_OneTimeFee__c > item.fields.baseonetimefee) {
                        item.fields.priceToDiscount = item.fields.Orig_OneTimeFee__c;
                    } else {
                        item.fields.priceToDiscount = null;
                    }
                });
                component.set('v.itemsToShow',itemsToShow);
                helper.changeProductSelectedIds(component);

                component.set('v.storeUrl', response.getReturnValue().storeUrl);
                helper.fireToggleSpinnerEvent(component, false);
			} else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
			console.log('TA_LCP229_CartMainProduct >> Helper >> retriveApexInfoCallback >> End');
		});
        $A.enqueueAction(action);
        console.log('TA_LCP229_CartMainProduct >> Helper >> retriveApexInfo >> End');
    },

    manageMainProductDetails : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Helper >> manageMainProductDetails >> Start');
        if(component.get('v.showMainProductDetails')) {
            component.set('v.showMainProductDetails', false);
            component.set('v.showMainProductAttributes', false);
        } else {
            let mainProductSelected = {};
            let listOfItems = component.get('v.itemsToShow');
            let itemSelectedId = event.currentTarget.id;
            listOfItems.forEach(function(item) {
                if(item.id == itemSelectedId) {
                    mainProductSelected = item;
                }
            });
            component.set('v.mainProductSelected', mainProductSelected);
            component.set('v.showMainProductDetails', true);
        }
        helper.fireToggleSpinnerEvent(component, false);
        console.log('TA_LCP229_CartMainProduct >> Helper >> manageMainProductDetails >> End');
    },

    addMainProductToCart : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Helper >> addMainProductToCart >> Start');
        component.set('v.insertedItemNumber', component.get('v.insertedItemNumber') + 1);
        component.set('v.currentAction', 'add');

        helper.manageCartStepEvt('TA_LCP226_CartContainer', 'manageAddToCart', component.get('v.mainProductSelected'));
        console.log('TA_LCP229_CartMainProduct >> Helper >> addMainProductToCart >> End');
    },

    removeMainProductFromCart : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Helper >> removeMainProductFromCart >> Start');
        component.set('v.insertedItemNumber', component.get('v.insertedItemNumber') - 1);
        component.set('v.currentAction', 'remove');

        let b2winResponse = component.get('v.b2winResponse');
        let itemToRemove = {};

        b2winResponse.cart.forEach(function(cartItem) {
            if(cartItem.id == component.get('v.mainProductSelected').fields.id) {
                itemToRemove = cartItem;
            }
        });

        helper.manageCartStepEvt('TA_LCP226_CartContainer', 'manageRemoveFromCart', itemToRemove);
        console.log('TA_LCP229_CartMainProduct >> Helper >> removeMainProductFromCart >> End');
    },

    manageFilterModal : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Helper >> manageFilterModal >> Start');
        component.set('v.showFilters', !component.get('v.showFilters'));
        component.set('v.renderPriceSlider', true);
        console.log('TA_LCP229_CartMainProduct >> Helper >> manageFilterModal >> End');
    },

    applyFilters : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Helper >> applyFilters >> Start');
        let listOfItems = component.get('v.listOfItems');
        let filterName = component.get('v.filterName');
        let filterBrand = component.get('v.filterBrand');
        let filterAvailability = component.get('v.filterAvailability');
        let priceRangeSelectedMinPrice = component.get('v.priceRangeSelectedMinPrice');
        let priceRangeSelectedMaxPrice = component.get('v.priceRangeSelectedMaxPrice');
        let listOfFilteredItems = [];

        listOfItems.forEach(function(item) {
            let checkFilter = true;
            if((filterName && !item.fields.productname.toLowerCase().includes(filterName.toLowerCase())) ||
                (item.fields.XC_Brand != filterBrand && filterBrand != 'All') ||
                (item.TA_availabilityLocalWarehouse == 0 && filterAvailability == 'Yes') ||
                (item.TA_availabilityLocalWarehouse > 0 && filterAvailability == 'No') ||
                ((item.fields.ReferenceOneTimeFee < priceRangeSelectedMinPrice && priceRangeSelectedMinPrice != null && priceRangeSelectedMinPrice != undefined) ||
                 (item.fields.ReferenceOneTimeFee > priceRangeSelectedMaxPrice && priceRangeSelectedMaxPrice != null && priceRangeSelectedMaxPrice != undefined))
            ) {
                checkFilter = false;
            }

            if(checkFilter) {
                listOfFilteredItems.push(item);
            }
        });

        component.set('v.listOfFilteredItems', listOfFilteredItems);

        helper.paginateListOfItems(component, event, helper);
        helper.retriveApexInfo(component, event, helper);

        component.set('v.showFilters', !component.get('v.showFilters'));
        console.log('TA_LCP229_CartMainProduct >> Helper >> applyFilters >> End');
    },

    clearAllFilters : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Helper >> clearAllFilters >> Start');
        component.set('v.filterName', undefined);
        component.set('v.filterBrand', undefined);
        component.set('v.filterAvailability', undefined);
        component.set('v.listOfFilteredItems', component.get('v.listOfItems'));
        component.set('v.priceRangeMinPrice', undefined);
        component.set('v.priceRangeMaxPrice', undefined);
        component.set('v.priceRangeSelectedMinPrice', undefined);
        component.set('v.priceRangeSelectedMaxPrice', undefined);

        helper.paginateListOfItems(component, event, helper);
        helper.retriveApexInfo(component, event, helper);

        component.set('v.showFilters', !component.get('v.showFilters'));
        console.log('TA_LCP229_CartMainProduct >> Helper >> clearAllFilters >> End');
    },

    manageCartStepEvt : function(handlerCmpName, actionName, actionParams, showButton) {
        console.log('TA_LCP229_CartMainProduct >> Helper >> manageCartStepEvt >> Start');
        let appEvent = $A.get("e.c:TA_LCE226_CartStep");
        appEvent.setParams({
            'handlerCmpName' : handlerCmpName,
            'actionName' : actionName,
            'actionParams' : actionParams,
            'showButton' : showButton
        });
        appEvent.fire();
        console.log('TA_LCP229_CartMainProduct >> Helper >> manageCartStepEvt >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP229_CartMainProduct >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP229_CartMainProduct",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP229_CartMainProduct >> Helper >> fireToggleSpinnerEvent >> End');
    },

    addRemoveFromCartResponse : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Helper >> addRemoveFromCartResponse >> Start');
        component.set('v.b2winResponse', event.getParam('actionParams').b2winResponse);
        if(component.get('v.currentAction') == 'add') {
            // let responseCart = event.getParam('actionParams').b2winResponse.cart;
            // responseCart.forEach(function(itemCart) {
            //     if(itemCart.fields.id == component.get('v.mainProductSelected').fields.id) {
            //         itemCart.listOfAttributes = component.get("v.mainProductSelected").listOfAttributes;
            //         helper.manageCartStepEvt('TA_LCP226_CartContainer', 'manageUpsertItems', itemCart);
            //     }
            // });
            let productsSelectedIds = component.get('v.productsSelectedIds');
            if(!productsSelectedIds.includes(component.get('v.mainProductSelected').fields.id)) {
                productsSelectedIds.push(component.get('v.mainProductSelected').fields.id);
                component.set('v.productsSelectedIds', productsSelectedIds);
            }
            helper.editAttribute(component, event, helper);
        } else if(component.get('v.currentAction') == 'remove') {
            let productsSelectedIds = component.get('v.productsSelectedIds');
            for(let i = 0; i < productsSelectedIds.length; i++) {
                if(productsSelectedIds[i] == component.get('v.mainProductSelected').fields.id) {
                    productsSelectedIds.splice(i, 1);
                }
            }
            component.set('v.productsSelectedIds', productsSelectedIds);
    
            component.set("v.showMainProductAttributes", false);
            helper.manageMainProductDetails(component, event, helper);
            helper.fireToggleSpinnerEvent(component, false);
        } else if(component.get('v.currentAction') == 'modify') {
            helper.editAttribute(component, event, helper);
        }
        console.log('TA_LCP229_CartMainProduct >> Helper >> addRemoveFromCartResponse >> End');
    },

    manageUpsertItemsResponse : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Helper >> manageUpsertItemsResponse >> Start');
        helper.manageCartStepEvt('TA_LCP226_CartContainer', 'manageSaveConfiguration', event.getParam('actionParams').b2winResponse);
        console.log('TA_LCP229_CartMainProduct >> Helper >> manageUpsertItemsResponse >> End');
    },

    manageSaveConfigurationResponse : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Helper >> manageSaveConfigurationResponse >> Start');
        component.set('v.b2winResponse', event.getParam('actionParams').b2winResponse);
        component.set('v.showMainProductDetails', false);
        component.set('v.showMainProductAttributes', false);
        helper.createMainProductList(component, event, helper);
        // let productsSelectedIds = component.get('v.productsSelectedIds');
        // if(!productsSelectedIds.includes(component.get('v.mainProductSelected').fields.id)) {
        //     productsSelectedIds.push(component.get('v.mainProductSelected').fields.id);
        //     component.set('v.productsSelectedIds', productsSelectedIds);
        //     helper.manageMainProductDetails(component, event, helper);
        //     helper.fireToggleSpinnerEvent(component, false);
        // }
        // helper.manageMainProductDetails(component, event, helper);
        // helper.fireToggleSpinnerEvent(component, false);
        console.log('TA_LCP229_CartMainProduct >> Helper >> manageSaveConfigurationResponse >> End');
    },

    changeProductSelectedIds : function(component) {
        console.log('TA_LCP229_CartMainProduct >> Helper >> changeProductSelectedIds >> Start');
        let itemsToShow = component.get('v.itemsToShow');
        //START FIX [#20210303AL] - Manage button continue
        let listOfItems = component.get('v.listOfItems');
        //END FIX [#20210303AL] - Manage button continue

        let insertedItemNumber = 0;
        let showButton = true;

        itemsToShow.forEach(function(item) {
            if(item != null && item.fields != null && component.get('v.productsSelectedIds') != null && component.get('v.productsSelectedIds').includes(item.fields.id)) {
                item.TA_selected = true;
                //START FIX [#20210303AL] - Manage button continue
                //insertedItemNumber++;
                //END FIX [#20210303AL] - Manage button continue
            } else {
                item.TA_selected = false;
            }
        });

        //START FIX [#20210303AL] - Manage button continue
        listOfItems.forEach(function(item) {
            if(item != null && item.fields != null && component.get('v.productsSelectedIds') != null && component.get('v.productsSelectedIds').includes(item.fields.id)) {
                item.TA_selected = true;
                insertedItemNumber++;
            } else {
                item.TA_selected = false;
            }
        })

        component.set('v.listOfItems', listOfItems);
        //END FIX [#20210303AL] - Manage button continue
        component.set('v.itemsToShow', itemsToShow);
        component.set('v.insertedItemNumber', insertedItemNumber);

        if(component.get('v.isBundle') && component.get('v.insertedItemNumber') < component.get('v.b2winCurrentBundleElement').fields.minqty) {
            showButton = false;
        }

        this.manageCartStepEvt('TA_LCP199_ButtonSection', 'manageRetrieveItemsFromBundleElement', {}, showButton);
        console.log('TA_LCP229_CartMainProduct >> Helper >> changeProductSelectedIds >> End');
    },

    createSlider : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Helper >> createSlider >> Start');
        if(component.get('v.priceRangeMinPrice') == null || component.get('v.priceRangeMinPrice') == undefined) {
            component.set('v.priceRangeMinPrice', 0);
            component.set('v.priceRangeSelectedMinPrice', 0);
        }

        if(component.get('v.priceRangeMaxPrice') == null || component.get('v.priceRangeMaxPrice') == undefined) {
            let listOfItems = component.get('v.listOfItems');
            let maxPrice = 0;

            listOfItems.forEach(function(item) {
                if(item.fields.ReferenceOneTimeFee > maxPrice) {
                    maxPrice = item.fields.ReferenceOneTimeFee;
                }
            });
            component.set('v.priceRangeMaxPrice', maxPrice);
            component.set('v.priceRangeSelectedMaxPrice', maxPrice);
        }

        let slider = document.getElementById('slider');
        let priceRangeMinPrice = component.get('v.priceRangeMinPrice');
        let priceRangeMaxPrice = component.get('v.priceRangeMaxPrice');
        let priceRangeSelectedMinPrice = component.get('v.priceRangeSelectedMinPrice');
        let priceRangeSelectedMaxPrice = component.get('v.priceRangeSelectedMaxPrice');

        noUiSlider.create(slider, {
            start: [priceRangeSelectedMinPrice, priceRangeSelectedMaxPrice],
            connect: true,
            range: {
                'min': priceRangeMinPrice,
                'max': priceRangeMaxPrice
            }
        });

        slider.noUiSlider.on('update', function(value, handle) {
            let val = parseInt(value[handle]);
            if(handle == 0) {
                component.set('v.priceRangeSelectedMinPrice', val);
            } else if(handle == 1) {
                component.set('v.priceRangeSelectedMaxPrice', val);
            }
        });

        component.set('v.renderPriceSlider', false);
        console.log('TA_LCP229_CartMainProduct >> Helper >> createSlider >> End');
    },

    checkAttribute : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Helper >> checkAttribute >> Start');
        let listOfAttributes = component.get("v.mainProductSelected").listOfAttributes;
        let errorMessage = '';
        listOfAttributes.forEach(function(attribute) {
            if(attribute.fields.value == '' && attribute.fields.required == 'Yes' && attribute.fields.readonly == 'false') {
                if(errorMessage != '') {
                    errorMessage += '<br>';
                }
                errorMessage += attribute.fields.name + ' is required. Insert a value for this field.';
            }
        });

        if(errorMessage != '') {
            component.set("v.showToastMessage", true);
            component.set("v.isError", true);
            component.set("v.toastMessage", errorMessage);
            console.log('TA_LCP229_CartMainProduct >> Helper >> checkAttribute >> End');
            return false;
        }

        console.log('TA_LCP229_CartMainProduct >> Helper >> checkAttribute >> End');
        return true;
    },

    getDynamicLookupValue : function(component, event, helper, listAttributeDynamicLookup, productName) {
        console.log('TA_LCP229_CartMainProduct >> Helper >> getDynamicLookupValue >> Start');
        let action = component.get('c.getDynamicLookupValue');
        let cart = component.get('v.b2winResponse').cart;
        let rType;
        let sType;

        let bundleSubType;
        cart.forEach(function(cartElement) {
            if(cartElement.fields.XC_Product_Type__c == 'Bundle') {
                bundleSubType = cartElement.fields.XC_Product_Subtype__c;
            }
        });

        cart.forEach(function(cartElement) {
            if(cartElement.fields.XC_Product_Type__c != 'Bundle' && cartElement.fields.XC_Product_Subtype__c == bundleSubType) {
                cartElement.listOfAttributes.forEach(function(elementAttribute) {
                    if(elementAttribute.fields.LicName == 'Tipologia PV') {
                        rType = elementAttribute.fields.value;
                    }
                });
            }

            cartElement.listOfFamilies.forEach(function(elementFamily) {
                if(elementFamily.fields.LicName == 'Photovoltaic Structure') {
                    cartElement.listOfAttributes.forEach(function(elementAttribute) {
                        if(elementAttribute.fields.LicName == 'Tipologia tetto') {
                            sType = elementAttribute.fields.value;
                        }
                    });
                }
            });
        });

        //TO DO - Da gestire sType e rType per Photovoltaic
        action.setParams({
            'listAttributeDynamicLookupSerialized' : JSON.stringify(listAttributeDynamicLookup),
            'legalEntity' : component.get("v.workOrder").XC_LegalEntity__c,
            'kType' : productName,
            'rType' : rType,
            'sType' : sType,
        });

        action.setCallback(this, function(response) {
            console.log('TA_LCP229_CartMainProduct >> Helper >> getDynamicLookupValueCallback >> Start');
            if(response.getState() == "SUCCESS") {
                let listOfAttributesDynamicLookup = JSON.parse(response.getReturnValue());
                let mainProductSelected = component.get("v.mainProductSelected");
                listOfAttributesDynamicLookup.forEach(function(attributesDynamicLookup) {
                    mainProductSelected.listOfAttributes.forEach(function(attribute) {
                        if(attributesDynamicLookup.id == attribute.id) {
                            attribute.listOfDomains = attributesDynamicLookup.listOfDomains;
                        }
                    });
                });
                component.set("v.mainProductSelected", mainProductSelected);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            helper.fireToggleSpinnerEvent(component, false);
            console.log('TA_LCP229_CartMainProduct >> Helper >> getDynamicLookupValueCallback >> End');
        });

        $A.enqueueAction(action);
        console.log('TA_LCP229_CartMainProduct >> Helper >> getDynamicLookupValue >> End');
    },

    editAttribute : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Helper >> editAttribute >> Start');
        let checkAttributesVisible = false;
        let listAttributeDynamicLookup = [];
        let productAttributes = component.get("v.mainProductSelected").listOfAttributes;
        let productName = component.get("v.mainProductSelected").fields.LicProductName;
        productAttributes.forEach(function(attribute) {
            if(attribute.fields.hidden == "false") {
                checkAttributesVisible = true;

                if(attribute.fields.type == "Dynamic Lookup") {
                    listAttributeDynamicLookup.push(attribute);
                }
            }
        });

        if(checkAttributesVisible) {
            component.set("v.showMainProductAttributes", true);
            if(listAttributeDynamicLookup.length) {
                helper.getDynamicLookupValue(component, event, helper, listAttributeDynamicLookup, productName);
            } else {
                helper.fireToggleSpinnerEvent(component, false);
            }
        }
        console.log('TA_LCP229_CartMainProduct >> Helper >> editAttribute >> End');
    },

    saveAttribute : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Helper >> saveAttribute >> Start');
        let responseCart = component.get('v.b2winResponse').cart;
        let itemToUpdate;
        responseCart.forEach(function(itemCart) {
            if(itemCart.fields.id == component.get('v.mainProductSelected').fields.id) {
                itemCart.listOfAttributes = component.get("v.mainProductSelected").listOfAttributes;
                itemToUpdate = itemCart;
            }
        });

        let product;
        let productCode;
        let price;
        let productSubType;
        itemToUpdate.listOfAttributes.forEach(function(attribute) {
            if(attribute.fields.type == 'Dynamic Lookup' && attribute.fields.hidden == 'false') {
                attribute.listOfDomains.forEach(function(domain) {
                    if(domain.Name == attribute.fields.value) {
                        product = domain.XC_ProductCategory__c;
                        productCode = domain.ProductCode;
                        price = domain.XC_Price__c;
                        productSubType = domain.XC_ProductSubType__c;
                    }
                });
            }
        });

        itemToUpdate.listOfAttributes.forEach(function(attribute) {
            if(attribute.fields.LicName == 'Producto') {
                attribute.fields.value = product;
            } else if(attribute.fields.LicName == 'Referencia') {
                attribute.fields.value = productCode;
            } else if(attribute.fields.LicName == 'Precio Endesa') {
                attribute.fields.value = price;
            } else if(attribute.fields.LicName == 'Product Subtype') {
                attribute.fields.value = productSubType;
            }
        });

        if(itemToUpdate) {
            helper.manageCartStepEvt('TA_LCP226_CartContainer', 'manageUpsertItems', itemToUpdate);
        }
        console.log('TA_LCP229_CartMainProduct >> Helper >> saveAttribute >> End');
    },

    modifyMainProductFromCart : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Helper >> modifyMainProductFromCart >> Start');
        component.set('v.currentAction', 'modify');
        let b2winResponse = component.get('v.b2winResponse');
        let itemToModify = {};

        b2winResponse.cart.forEach(function(cartItem) {
            if(cartItem.id == component.get('v.mainProductSelected').fields.id) {
                itemToModify = cartItem;
            }
        });
        helper.manageCartStepEvt('TA_LCP226_CartContainer', 'manageModifyFromCart', itemToModify);
        console.log('TA_LCP229_CartMainProduct >> Helper >> modifyMainProductFromCart >> End');
    }
})
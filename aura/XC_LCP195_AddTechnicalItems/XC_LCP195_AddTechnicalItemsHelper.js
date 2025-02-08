({
    getProduct2 : function(component, helper) {
        component.set("v.spinner", true);
        let action = component.get("c.getLimitedProduct2");
		let listParam = {
            pageSize : component.get("v.pageSize").toString(),
            pageNumber : component.get("v.pageNumber").toString(),
			orderItemId : component.get("v.recordId"),
            //woliCountry : component.get("v.country"),
            rtWoli: component.get("v.rtWoli"),                  // retrieve country from contest product required
            searchMaterial : component.get("v.showMaterials"),
            segment : component.get("v.woliSegment"),
            woliId : component.get("v.woliRecordId")
        };
        action.setParams({ 
            'listParam':JSON.stringify(listParam)
		})
        action.setCallback(this,function(response){
            let state = response.getState();
            console.log('@@@ getProduct2 - state:' + state);
            if (state === "SUCCESS") {
                //console.log('@@@ getProduct2 - Response Time: '+((new Date().getTime())-requestInitiatedTime));
                let result = response.getReturnValue();
                let objInfo = [];
                objInfo = JSON.parse(result.objectInfo);
                component.set("v.showFlagForMaterials", objInfo['showSelectMaterial']);
                if( objInfo['product2List'].length < component.get("v.pageSize")){
                    component.set("v.isLastPage", true);
                } else{
                    component.set("v.isLastPage", false);
                }
                console.log('@@@ getProduct2 - set isLastPage:' + component.get("v.isLastPage"));
                //Modify response to include the page number as well 
                //in the id attribute of each row
                //This will help us to filter out the rows displayed on each page               
                objInfo['product2List'].forEach(function(row) {
                	row.Id = row.Id+'-'+ component.get("v.pageNumber").toString();
                });
                
                if( objInfo['product2List'].length > 0){
                    let cntrId = objInfo['product2List'][0].contractId;
                    console.log('@@@ getProduct2 - cntrId:' + cntrId);
                    component.set("v.contractId", cntrId);
                }
                component.set("v.resultSize", objInfo['product2List'].length);
                component.set("v.data", objInfo['product2List']); 
                component.set("v.country", objInfo['country']);
                //Set selected rows with our selection attribute which has id of each attribute
				component.find("product2DataTable").set("v.selectedRows",component.get("v.selection"));
                component.set("v.hasPageChanged", false);
            }
            component.set("v.spinner", false);
        });
        //let requestInitiatedTime = new Date().getTime();
        $A.enqueueAction(action);
    },
	
    /* if called is from ProductRequired Function */
    getOrdItemFromWoli : function(component, event,helper){
        //DP performance ----- component.set("v.spinner", true);
        console.log('@@@@ getOrdItemFromWoli:' + component.get("v.woliRecordId"));
        let action = component.get("c.getOrderItemFromWoli");
        action.setParams({
           	'woliId' : component.get("v.woliRecordId")
		});
       
        action.setCallback(this,function(response){
            let state = response.getState();
             console.log('@@@@ getOrdItemFromWoli - countrywoli state:' + state);
            if (state === "SUCCESS"){
                console.log('@@@@ getOrdItemFromWoli response:' + response.getReturnValue());
                if(response.getReturnValue() != null){
					component.set("v.country", response.getReturnValue()[0].country);
                    component.set("v.rtWoli", response.getReturnValue()[0].rtWoli);
                    component.set("v.workOrderId", response.getReturnValue()[0].workOrderId);
                    component.set("v.woliSegment", response.getReturnValue()[0].segment);
                    component.set("v.woliLegalEntity", response.getReturnValue()[0].legalEntity);
                    //DP performance ----- helper.getProduct2(component, helper);
				}	
			}
		});
		$A.enqueueAction(action);
	},
    
    /*getCountryValue : function(component, helper){
        console.log('@@@ getCountryValue - id :' + component.get("v.recordId"));
        let action = component.get("c.getOrderItemCountry");
        let orderItemId =  component.get("v.recordId");
        action.setParams({
			'orderItemId' : orderItemId
		});
        action.setCallback(this,function(response){
            let state = response.getState();
            console.log('@@@ getCountryValue -  state:' + state);
            if (state === "SUCCESS"){
                if(response.getReturnValue() != null){
                    component.set("v.country", response.getReturnValue());
                }
            }
             console.log('@@@ getCountryValue -  Set Country:' + component.get("v.country"));
        });
        $A.enqueueAction(action);
    },*/
    
    filtersNotIsEmpty : function(component, event, helper){
        if(component.find("Product2Name").get("v.value")){
            return true; 
        }
        /*if(component.find("FamilyName").get("v.value") && component.find("FamilyName").get("v.value") != 'None'){
           return true; 
        }*/
        if(component.find("TypeName").get("v.value")){
            return true; 
        }
        if(component.find("SapCode").get("v.value")){
            return true; 
        }
        if(component.find("PositionName").get("v.value")){
            return true;
        }
        if(component.find("FlagApplyFilter").get("v.value")){
            return true;
        }
        return false;
	},
    
    search : function(component, event, helper){
        /*let country = component.get("v.country");
        console.log('@@@@ search - search country:' + country);
        if(country != undefined && country != null){*/
        component.set("v.spinner", true);
        var filterMap = [component.find("Product2Name").get("v.value"),component.find("TypeName").get("v.value"),component.find("SapCode").get("v.value"),component.find("PositionName").get("v.value"),component.get("v.flagDisableCatFilter"), component.get("v.showAvailable")]
        //filterMap.set('typeName', component.find("TypeName").get("v.value"));
        //filterMap.set('sapCode', component.find("SapCode").get("v.value"));
        //filterMap[0] = component.find("Product2Name").get("v.value");
        //filterMap[1] = component.find("TypeName").get("v.value");
        //filterMap[2] = component.find("SapCode").get("v.value");


        let listParam = {
                    pageSize : component.get("v.pageSize").toString(),
                    pageNumber : component.get("v.pageNumber").toString(),
        			orderItemId : component.get("v.recordId"),
                    //woliCountry : component.get("v.country"),
                    rtWoli: component.get("v.rtWoli"),                  // retrieve country from contest product required
                    searchMaterial : component.get("v.showMaterials"),
                    segment : component.get("v.woliSegment"),
                    woliId : component.get("v.woliRecordId"),
                    searchFilters :filterMap
                };


        
        let action = component.get("c.getLimitedProduct2");
        action.setParams({
            'listParam':JSON.stringify(listParam)
        });
        action.setCallback(this,function(response){
            component.set("v.noItemFound", false);
            let state = response.getState();
            console.log('@@@@ search - search state:' + state);
            if (state === "SUCCESS"){                  
                 //console.log('@@@ getProduct2 - Response Time: '+((new Date().getTime())-requestInitiatedTime));
                let result = response.getReturnValue();
                let objInfo = [];
                objInfo = JSON.parse(result.objectInfo);
                component.set("v.showFlagForMaterials", objInfo['showSelectMaterial']);
                if( objInfo['product2List'].length < component.get("v.pageSize")){
                    component.set("v.isLastPage", true);
                } else{
                    component.set("v.isLastPage", false);
                }

                console.log('@@@ getProduct2 - set isLastPage:' + component.get("v.isLastPage"));
                //Modify response to include the page number as well
                //in the id attribute of each row
                //This will help us to filter out the rows displayed on each page
                objInfo['product2List'].forEach(function(row) {
                    row.Id = row.Id+'-'+ component.get("v.pageNumber").toString();
                });

                if( objInfo['product2List'].length > 0){
                    let cntrId = objInfo['product2List'][0].contractId;
                    console.log('@@@ getProduct2 - cntrId:' + cntrId);
                    component.set("v.contractId", cntrId);
                }
                component.set("v.resultSize", objInfo['product2List'].length);
                component.set("v.data", objInfo['product2List']);
                component.set("v.country", objInfo['country']);
                //Set selected rows with our selection attribute which has id of each attribute
                component.find("product2DataTable").set("v.selectedRows",component.get("v.selection"));
                component.set("v.hasPageChanged", false);

                /*if(objInfo['product2List'].length > 0){
                    component.set("v.noItemFound", false);
                }
                else{
                    component.set("v.noItemFound", true);
                }*/

            }
            component.set("v.spinner", false);
        });
        $A.enqueueAction(action);
        /*}*/
    },

    addTechnicalItems : function(component, event, helper){
        component.set("v.spinner", true);
        let recordIdNavigate;
        console.log('@@@@ prodres:' +component.get("v.ProdRes"));
        let items = component.get("v.SelectProd") ;
        if(!component.get("v.contestStartCI")){
        items = items.concat(component.get("v.ProdRes"));
        }
        let items2 = component.get("v.selProd") ;
        if(!component.get("v.contestStartCI")){
        items2 = items2.concat(component.get("v.selection"));
        }
        console.log('@@@@ items - state:' + JSON.stringify(items2));
        let contestCI = component.get("v.contestStartCI"); 
        let listParam = {
            rows: JSON.stringify(items2), 	
            contractId : component.get("v.contractId"),
            ordItem: component.get("v.orderItemRecord"),
            woliId:component.get("v.woliRecordId"),
            wbeElement: component.get("v.wbeElement"),
            costCenter: component.get("v.costCenter"),
            contestCI:contestCI,
			mapManualPrice: JSON.stringify(component.get("v.manualMapPrice")),
            workOrderId : component.get("v.workOrderId"),
            rtWoli : component.get("v.rtWoli"),
            segment : component.get("v.woliSegment"),
            legalEntity : component.get("v.woliLegalEntity"),
        };
        console.log('@@@@ check 0:' );
        if(items.length > 0 || items2.length > 0){
            console.log('@@@@ check 1:' );
            let action = component.get("c.generateTechnicalItems");
            action.setParams({
              'listParam' : JSON.stringify(listParam),
              'selectedProduct' : items,
              'mapManualPrice': JSON.stringify(component.get("v.manualMapPrice"))
            });

            if(contestCI) {
               recordIdNavigate = component.get("v.orderItemRecord").Id;
            }else{
               recordIdNavigate = component.get("v.woliRecordId"); 
            }
            action.setCallback(this,function(response){
                let state = response.getState();
                console.log('@@@@ check 2:' );
                let res = response.getReturnValue(); //[R2 CR704 14.03.2022 sooraji.sajan@accenture.com - raffaele.sojka@accenture.com]
                if (state === "SUCCESS"){
                    //[START R2 CR704 14.03.2022 sooraji.sajan@accenture.com - raffaele.sojka@accenture.com]
                    if(!res.Success && res.resultMessage === 'ErrorPosCode'){
                        component.find('notifLib').showToast({
                        "variant": "Error",
                        "title": "Error!",
                        "message": "Errore. La posizione dei prodotti inseriti non è coerente con la posizione specificata a livello di partner payment."
                       });
                    }
                else{
                    //[END R2 CR704 14.03.2022 sooraji.sajan@accenture.com - raffaele.sojka@accenture.com]
                    let type = response.getReturnValue().typeMessage;
                    let message = response.getReturnValue().resultMessage;
                    let titleMessage = response.getReturnValue().titleMessage;
                    let navEvt = $A.get("e.force:navigateToSObject");
                    setTimeout(function(){ location.reload(); }, 2000);
                    navEvt.setParams({
                        "recordId": recordIdNavigate, //ordItem.Id,
                        "slideDevName": "related"
                    });
                    
                    helper.showDetailedToast(component, titleMessage, message, type, "4000");
                    navEvt.fire();
                } //[R2 CR704 22.03.2022 sooraji.sajan@accenture.com - raffaele.sojka@accenture.com]
                }else{

                }    
                component.set("v.spinner", false);
            });
            $A.enqueueAction(action);
        }
        else{
            component.find('notifLib').showToast({
                "variant": "Error",
                "title": "Error!",
                "message": "Error! There are no products to insert"
            });
        }
    },

    /*Meghana Begin*/
    uploadCSV : function(component, event, helper){
        let action = component.get("c.uploadCSVFile");
        action.setParams({
            contestCI: component.get("v.contestStartCI"), recordId: component.get("v.recordId"), woliId : component.get("v.woliRecordId")
        })
        action.setCallback(this,function(response){
            let state = response.getState();
            let res = response.getReturnValue();
            
            if (state === "SUCCESS" && res == null) {
                component.find('notifLib').showToast({
                    "variant": "Error",
                    "title": "Error!",
                    "message": "Attenzione. Impossibile effettuare il caricamento per mancata valorizzazione contratto passivo."
                });
            }
            else{
                console.log('@@@@ finalurl' + res);
                component.set("v.TemplateURL", res);
                component.set("v.uploadModalOpen", true);
                console.log('@@@@ woli id ' + component.get("v.woliRecordId"));
            }
        });
        $A.enqueueAction(action);
    },

    saveCSV : function(component, file, helper){
        let action = component.get("c.saveCsvFile");
        action.setParams({
            contentDocumentId: file[0].documentId, contestCI: component.get("v.contestStartCI"), recordId: component.get("v.recordId"), woliId : component.get("v.woliRecordId")
        })
        action.setCallback(this,function(response){
            let state = response.getState();
            let res = response.getReturnValue();
            if (state === "SUCCESS" && res != null) {
                component.find('notifLib').showToast({
                    "variant": "success",
                    "title": "success",
                    "message": "A breve sarà prodotto un file di esito. Controlla il risultato del caricamento nella sezione Attachements."
                });
            let arr = [];
            let arr2 = [];
            for(const x of res){
                arr.push(x);
                arr2.push(x.id);
              }
            component.set("v.ProdRes", arr);
            component.set("v.selProd", arr2);
            console.log('@@@@ Result prod:' +arr);
            console.log('@@@@ Manualmapprice:' +component.get("v.manualMapPrice"));
            }
            else{
                component.find('notifLib').showToast({
                    "variant": "Error",
                    "title": "Error!",
                    "message": "Impossibile effettuare il caricamento. Non sono ammessi Product Code Duplicati"
                });
            }
        });
        $A.enqueueAction(action);
    },
    /*Meghana End*/
    
    showDetailedToast : function(component, title, message, type, duration) {
        component.find('notifLib').showToast({
            "title": title,
            "message": message,
            "duration": duration,
            "variant": type
        });
    },
    checkValidItem : function(component, event, helper){
          let action = component.get("c.checkConfItem");
          action.setParams({
              'recordId': component.get("v.recordId")
          })
          action.setCallback(this,function(response){
              let state = response.getState();
              let res = response.getReturnValue();
              if (state === "SUCCESS" && res != null) {
                  helper.showDetailedToast(component, '', res, "error", "5000");
                  $A.get("e.force:closeQuickAction").fire();
              }
              component.set("v.spinner", false);
          });
          $A.enqueueAction(action);
    }
 })
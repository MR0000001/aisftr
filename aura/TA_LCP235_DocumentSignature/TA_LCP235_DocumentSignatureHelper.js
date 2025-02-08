({
    getInitInformation: function (cmp, evt, hlp, isRefresh) {
        console.log('TA_LCP235_DocumentSignature >> Helper >> getInitInformation >> Start');
        cmp.set("v.showSpinner",true);
        cmp.set('v.general', JSON.parse(cmp.get('v.fieldSet')).general);
        cmp.set('v.customerCardBg', $A.get('$Resource.TA_Images') + '/imgs/' + cmp.get('v.general.bgImage'));
        cmp.set('v.title', $A.getReference("$Label.c." + cmp.get('v.general').defaultTitle));

        let action = cmp.get("c.getInitInformation");
        action.setParams({
            "workOrderId": cmp.get('v.workOrderId')
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if(state === "SUCCESS") {
                cmp.set("v.showSpinner",false);
                let result = response.getReturnValue();
                let objInfo = [];

                if(result.success) {
                    objInfo = JSON.parse(result.objectInfo);
                    cmp.set('v.orderId', objInfo["orderId"]);
                    cmp.set("v.isCommunity", objInfo['isCommunity']);
                    cmp.set("v.sessionId",objInfo["sessionId"]);
                    hlp.subscribe(cmp, evt, hlp);
                }
                hlp.getDataInit(cmp, evt, hlp, isRefresh); 

                if(!isRefresh) {
                    hlp.fireSendInitStateEvt(cmp, true);
                    cmp.set('v.isInitialized', true);
                } else {
                    hlp.fireToggleSpinnerEvent(cmp, false);
                }

            } else if(response.getState() == "ERROR") {
                cmp.set("v.showToastMessage", true);
                cmp.set("v.isError", true);
                cmp.set("v.toastMessage", JSON.stringify(response.getError()));
                cmp.set("v.showSpinner",false);
            }
        });

        $A.enqueueAction(action);
        console.log('TA_LCP235_DocumentSignature >> Helper >> getInitInformation >> End');
    },

    getData: function (cmp, evt, hlp) {
        console.log('TA_LCP235_DocumentSignature >> Helper >> getData >> Start');
        let action = cmp.get("c.getDocumentSignatures");
        action.setParams({orderId : cmp.get("v.orderId")});
        action.setCallback(this,function(response) {
            if(response.getState() == "SUCCESS") {
                if(response.getReturnValue() != null) {
                    cmp.set('v.data',response.getReturnValue());
                }
            } else if(response.getState() == "ERROR") {
                cmp.set("v.showToastMessage", true);
                cmp.set("v.isError", true);
                cmp.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            cmp.set("v.showSpinner",false);
        });

        $A.enqueueAction(action);
        console.log('TA_LCP235_DocumentSignature >> Helper >> getData >> End');
    },

    getDataInit: function (cmp, evt, hlp, isRefresh) {
        console.log('TA_LCP235_DocumentSignature >> Helper >> getDataInit >> Start');
        hlp.callMethod(cmp, 'getDocumentSignatures', { orderId: cmp.get('v.orderId') })
            .then(r => {
                cmp.set('v.data', r);
            })
            .catch(e => {
                //hlp.notifyError(e)
            })
        console.log('TA_LCP235_DocumentSignature >> Helper >> getDataInit >> End');
    },

    subscribe: function(cmp, evt, hlp) {
        console.log('TA_LCP235_DocumentSignature >> Helper >> subscribe >> Start');
        let cometDNotConnected = $.cometd.isDisconnected();
        let orderId = cmp.get("v.orderId");

        if (cometDNotConnected) {
            $.cometd.websocketEnabled = false;
            let sid = cmp.get("v.sessionId");
            $.cometd.init({
                url: '/cometd/47.0/',
                requestHeaders: { Authorization: 'OAuth ' + sid },
                appendMessageTypeToURL: false
            });
        }

        $.cometd.subscribe('/event/XC_DigitalSignature__e', function(message) {
            if (message.data.payload.XC_SignerId__c == orderId) {
                cmp.set("v.showSpinner",true);
                hlp.getData(cmp, message, hlp);
            }
        });
        console.log('TA_LCP235_DocumentSignature >> Helper >> subscribe >> End');
    },

    notifySuccess: function (message, title) {
        console.log('TA_LCP235_DocumentSignature >> Helper >> notifySuccess >> Start');
        let toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            'title': title || $A.get('$Label.c.XC_CL_Success'),
            'message': message,
            'type': 'success',
            'duration': 8000
        });
        toastEvent.fire();
        console.log('TA_LCP235_DocumentSignature >> Helper >> notifySuccess >> End');
    },

	notifyError: function (message, title) {
        console.log('TA_LCP235_DocumentSignature >> Helper >> notifyError >> Start');
		var toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({
			'title': title || 'Error',
			'message': message,
			'type': 'error',
			'duration': 8000
		});
		toastEvent.fire();
        console.log('TA_LCP235_DocumentSignature >> Helper >> notifyError >> End');
	},

	isSalesforce1: function () {
        console.log('TA_LCP235_DocumentSignature >> Helper >> isSalesforce1 >> Start');
        console.log('TA_LCP235_DocumentSignature >> Helper >> isSalesforce1 >> End');
		return $A.get('$Browser.formFactor') !== 'DESKTOP';
	},

	openTab: function (scope) {
        console.log('TA_LCP235_DocumentSignature >> Helper >> openTab >> Start');
		$A.get('e.force:navigateToObjectHome').fire({
			'scope': scope
		});
        console.log('TA_LCP235_DocumentSignature >> Helper >> openTab >> End');
	},

	openListView: function (scope, listViewId) {
        console.log('TA_LCP235_DocumentSignature >> Helper >> openListView >> Start');
		$A.get('e.force:navigateToList').fire({
			'scope': scope,
			'listViewId': listViewId
		});
        console.log('TA_LCP235_DocumentSignature >> Helper >> openListView >> End');
	},

    callMethod: function (cmp, method, params) {
        console.log('TA_LCP235_DocumentSignature >> Helper >> callMethod >> Start');
        console.log('TA_LCP235_DocumentSignature >> Helper >> callMethod >> End');
        let _helper = this;
		return new Promise((resolve, reject) => {
			var me = this
			$A.getCallback(function () {
				var action = cmp.get('c.' + method)
				if (params) action.setParams(params)
				action.setCallback(me, function (res) {
					if (res.getState() === 'SUCCESS') {
						resolve(res.getReturnValue())
                        // START FIX [ADC13/07/2021] ENXCRM-167
                        let data = res.getReturnValue();
                        console.log('@@@@ data: ' + JSON.stringify(data));                        
                        if(data && data.length > 0){            
                            if(data[0].XC_Step__c == '3') _helper.fireValidationEvt(cmp,[],'TA_LCP235_DocumentSignature');
                            else _helper.fireValidationEvt(cmp,[$A.get('$Label.c.TA_DigitalSignatureError')],'TA_LCP235_DocumentSignature');
                        } 
                        else _helper.fireValidationEvt(cmp,[$A.get('$Label.c.TA_DigitalSignatureError')],'TA_LCP235_DocumentSignature');             
                        // END FIX [ADC13/07/2021] ENXCRM-167
					} else if (cmp.isValid() && res.getState() === 'ERROR') {
						var error = 'Si è verificato un errore'
						if (res.getError() && res.getError()[0] && res.getError()[0].pageErrors && res.getError()[0].pageErrors[0]) {
							error = res.getError()[0].pageErrors[0].message
						} else if (res.getError()[0]) {
							error = res.getError()[0].message
						}
                        // START FIX [ADC13/07/2021] ENXCRM-167
                        _helper.fireValidationEvt(cmp,[$A.get('$Label.c.TA_DigitalSignatureError')],'TA_LCP235_DocumentSignature');             
                        // END FIX [ADC13/07/2021] ENXCRM-167
						reject(error)
					} else {
                        // START FIX [ADC13/07/2021] ENXCRM-167
                        _helper.fireValidationEvt(cmp,[$A.get('$Label.c.TA_DigitalSignatureError')],'TA_LCP235_DocumentSignature');             
                        // END FIX [ADC13/07/2021] ENXCRM-167
						reject(res)
					}
				})
				$A.enqueueAction(action)
			})()
		})
	},

    fireSendInitStateEvt : function(component, isInitialized) {
        console.log('TA_LCP235_DocumentSignature >> Helper >> fireSendInitStateEvt >> Start');
        let sendInitStateEvt = component.getEvent("sendInitStateEvt");
        sendInitStateEvt.setParams({
            "componentName" : "TA_LCP235_DocumentSignature",
            "initState" : isInitialized
        });
        sendInitStateEvt.fire();
        console.log('TA_LCP235_DocumentSignature >> Helper >> fireSendInitStateEvt >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP235_DocumentSignature >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP235_DocumentSignature",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP235_DocumentSignature >> Helper >> fireToggleSpinnerEvent >> End');
    },

    fireValidationEvt : function(component, errors, cmpName) {
        console.log('TA_LCP235_DocumentSignature >> Helper >> fireValidationEvt >> Start');
        let validationEvt = $A.get("e.c:TA_LCE199_Validation");
        validationEvt.setParams({
            "cmpName" : cmpName,
            "errors" : errors,
            "validate" : errors.length > 0 ? false : true
        }); 
        validationEvt.fire();
        console.log('TA_LCP235_DocumentSignature >> Helper >> fireValidationEvt >> End');
    }
})
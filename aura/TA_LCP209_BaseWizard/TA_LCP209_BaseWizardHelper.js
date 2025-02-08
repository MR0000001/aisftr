({
    initialize : function(component) {
        console.log('TA_LCP209_BaseWizard >> Helper >> initialize >> Start');
        component.set("v.isSpinnerVisible", true);
        let action = component.get('c.initialize');

        action.setCallback(this, function(response) {
            console.log('TA_LCP209_BaseWizard >> Helper >> initializeCallback >> Start');
            if(response.getState() == "SUCCESS") {
                if(response.getReturnValue() != null) {
                    let result = response.getReturnValue();
                    let url = $A.get('$Resource.TA_Images');
                    component.set('v.customerCardBg', url + '/imgs/customer-card-background.svg');
                    component.set('v.communityBaseUrl', result.communityBaseUrl);
                    component.set('v.userLanguage', result.userLanguage);
                    component.set('v.userName', result.userName);
                    component.set('v.userPermissionSetName', result.userPermissionSetName);

                    let processType = '';
                    if(component.get('v.userPermissionSetName').includes('B2G')) {
                        processType = 'B2G';
                    } else if(component.get('v.userPermissionSetName').includes('B2B')) {
                        processType = 'B2B';
                    } else processType = 'B2C';

                    component.set('v.processType', processType);
                    component.set('v.isInitialized', true);
                }
            } else if(response.getState() == "INCOMPLETE" || response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP209_BaseWizard >> Helper >> initializeCallback >> End');
        });

        $A.enqueueAction(action);
        console.log('TA_LCP209_BaseWizard >> Helper >> initialize >> End');
    },

    redirectToPage : function(component, redirectParam, isPage) {
        console.log('TA_LCP209_BaseWizard >> Helper >> redirectToPage >> Start');
        component.set("v.isSpinnerVisible", true);
        let redirectUrl = component.get('v.communityBaseUrl') +'/';
        isPage ? redirectUrl = redirectUrl.concat('s/'.concat(redirectParam)) : redirectUrl = redirectUrl.concat(redirectParam);
        window.location.href = redirectUrl;
        console.log('TA_LCP209_BaseWizard >> Helper >> redirectToPage >> End');
    },

    catchAppointmentPreviewEvt : function(component, event) {
        console.log('TA_LCP209_BaseWizard >> Helper >> catchAppointmentPreviewEvt >> Start');
        const eventParams = event.getParams();
        this.redirectToPage(component, eventParams.urlToRedirect, false);
        console.log('TA_LCP209_BaseWizard >> Helper >> catchAppointmentPreviewEvt >> End');
    },

    catchToggleSpinnerEvt : function(component, event) {
        console.log('TA_LCP209_BaseWizard >> Helper >> catchToggleSpinnerEvt >> Start');
        const eventParams = event.getParams();
        component.set("v.isSpinnerVisible", eventParams.toggleSpinner);
        console.log('TA_LCP209_BaseWizard >> Helper >> catchToggleSpinnerEvt >> End');
    },

    isEmpty : function(obj) {
        console.log('TA_LCP209_BaseWizard >> Helper >> isEmpty >> Start');
        for(var key in obj) {
            if(obj.hasOwnProperty(key)) {
                console.log('TA_LCP209_BaseWizard >> Helper >> isEmpty >> End');
                return false;
            }
        }
        console.log('TA_LCP209_BaseWizard >> Helper >> isEmpty >> End');
        return true;
    },
    //ENXCRM-45 start
    setCookie : function(cname, cvalue, exdays) {
        var d = new Date();
        var expires;
        if (exdays != "" && exdays != null) {
            d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
            expires = "expires="+d.toUTCString();
        } else {
            expires = "expires=0";
        }
        document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
    }, 

    getCookie : function(cname) {
        var name = cname + "=";
        var ca = document.cookie.split(';');
        for(var i = 0; i < ca.length; i++) {
            var c = ca[i];
            while (c.charAt(0) == ' ') {
                c = c.substring(1);
            }
            if (c.indexOf(name) == 0) {
                return c.substring(name.length, c.length);
            }
        }
        return "";
    }
    //ENXCRM-45 end
})
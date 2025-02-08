/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 09/07/2019
* @description XC_LCP128_LeadConverted – Component for Lead Converted
*/

({
    doInit : function(component, event, helper) {
        console.log('@@@ Init for LCP128');
        let mapString = component.get('v.mapForLeadString');
        let mapForLead = JSON.parse(mapString); 
        console.log('@@@ mapForLead ---> ', mapForLead);
        let account = mapForLead.account;
        let contact = mapForLead.contact;
        let community = mapForLead.community;
        let opportunityCreated = mapForLead.opportunityCreated;
        component.set('v.productCategoryOfInterest', mapForLead.productCategoryOfInterest);

        component.set('v.isCommunity', community);

        // For Account and Contact
        let urlAccount = '';
        let urlContact = '';
        if(!community) {
            urlAccount = '/one/one.app?#/sObject/' + account.Id + '/view';
            urlContact = '/one/one.app?#/sObject/' + contact.Id + '/view';
        } /*else {
            urlAccount = '/partner/s/account/' + account.Id;
            urlContact = '/partner/s/contact/' + contact.Id;
        }*/
        component.set('v.urlAccount', urlAccount);
        component.set('v.urlContact', urlContact);
        if(('FirstName' in contact) && ('LastName' in contact)) {
            component.set('v.nameContact', contact.FirstName + ' ' + contact.LastName);
        }
        if(('XC_PhonePrefix__c' in contact) && ('XC_ContactPhone__c' in contact)) {
            component.set('v.phoneContact', contact.XC_PhonePrefix__c + ' ' + contact.XC_ContactPhone__c);
        }
        if(('XC_MainPhonePrefix__c' in account) && ('XC_AccountMainPhone__c' in account)) {
            component.set('v.phoneAccount', account.XC_MainPhonePrefix__c + ' ' + account.XC_AccountMainPhone__c);
        }
        component.set("v.account", account);
        component.set("v.contact", contact);
        component.set("v.type", mapForLead.type);
        console.log('@@@ RecordType ---> ', component.get('v.type'));
        console.log('@@@ account ---> ', account);
        console.log('@@@ contact ---> ', contact);
        console.log('@@@ urlAccount ---> ', urlAccount);
        console.log('@@@ urlContact ---> ', urlContact);

        // For opportunity:
        component.set("v.opportunityCreated", opportunityCreated);
        console.log('@@@ opportunityCreated ---> ', opportunityCreated);
        if(opportunityCreated) {
            let opportunity = mapForLead.opportunity;
            component.set("v.opportunity", opportunity);
            component.set("v.opportunityCreated", opportunityCreated);
            let urlOpportunity = '';
            if(!community) {
                urlOpportunity = '/one/one.app?#/sObject/' + opportunity.Id + '/view';
            } 
            /*else {
                urlOpportunity = '/partner/s/opportunity/' + opportunity.Id;
            }*/
            component.set('v.urlOpportunity', urlOpportunity);
            console.log('@@@ urlOpportunity ---> ', urlOpportunity);
            console.log('@@@ opportunity ---> ', opportunity);
        }
        
        let warningMessage = component.get('v.warningMessage');
        console.log('@@@@ warning message -> ', warningMessage);
        if(warningMessage != '') {
            let toastEventWarning = $A.get("e.force:showToast");
            toastEventWarning.setParams({
                title: $A.get("$Label.c.XC_CL_Warning"),
                message: warningMessage,
                key: 'info_alt',
                type: 'warning',
                mode: 'dismissible'
            });
            toastEventWarning.fire();
        }
        
        console.log('@@@ End for LCP128');
    },

    handleClick : function(component, event, helper) {
        let auraid = event.getSource().getLocalId();
        component.set('v.tabLabel', auraid);
        let targetPageReference = {
            type: 'standard__recordPage',
            attributes: {
                "recordId": component.get('v.'+auraid.toLowerCase()).Id,
                "actionName": "view"
            },
            state: {
                "c__recordId": component.get('v.'+auraid.toLowerCase()).Id,
                "c__closeSource": true
            }
        };
        component.set("v.targetPageReference", targetPageReference);
        helper.executeAptNavigation(component, event, helper);
    }
    
})
/*
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 10/10/2018
* @date Modification 25/10/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_LCP028_CreateOppFromContact – Controller class for component for Create Opportunity
**/

({

	doInit : function(component, event, helper) {
        //helper.doInit(component, event, helper); //R1.1 2022 - NR2459
        helper.checkOptyCreation(component, event, helper);
	},
    
    goBack : function(component, event, helper) {
        helper.goBack(component, event, helper);
    },

    createOpp : function(component, event, helper) {
        helper.createOpp(component, event, helper);
    },
    createLead : function(component, event, helper) {
        helper.createLead(component, event, helper);
    },
    createAccount : function(component, event, helper) {
        helper.createAccount(component, event, helper);
    },
    onGroup : function(component, event, helper) {
         helper.setCurrentRT(component, event);
    }
    
})
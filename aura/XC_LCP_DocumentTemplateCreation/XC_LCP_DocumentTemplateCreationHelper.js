({
    Populatefields : function(component, event, helper){
        console.log("First "+ component.get("v.Templatechoice")) ;
        let action = component.get("c.PopulatefieldsfromWOLI");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        if(component.get("v.Templatechoice") !== "Standard"){
            console.log("Inside else ") ;
            action = component.get("c.ClonefieldsfromTemplate");
            action.setParams({
                recordId: component.get("v.recordId"),
                Template: component.get("v.Templatechoice")
            });
        }
        action.setCallback(this,function(response){
            console.log("Second ") ;
            let state = response.getState();
            let res = response.getReturnValue();
            
            if (state === "SUCCESS" && res != null) {

                console.log("Does it come here ? " + res ) ;
                console.log("Resultant  " + res.AccountName ) ;
                console.log("What is the value ? " + component.get("v.Templatechoice") ) ;
                var prepopulate={
                    XC_Zone__c  : res.AccountZone,
                    XC_InternalID__c : res.InteralId,
                    XC_WorkOrder__c : res.WorkOrder,
                    XC_ContractNumber__c : res.ContractNumber,
                    XC_ContractSAP__c : res.ContractSAP,
                    //XC_PartnerId__c : res.AccountName,  //Deav 04.04.2022 CR755 Commented
                    XC_AccountId__c : res.WoliAccountName,
                    XC_Description__c : res.Description,
                    //XC_AccountMainPhone__c : res.AccountMainPhone,
                    XC_SubcontratorCompany__c : res.Subcontractor,
                    XC_Works_Lgs_81_08__c : res.Workslgs,
                    XC_Number_contracting_companies__c : res.NumberCompany,
                    XC_Entities_man_days__c : res.EntitiesDay,
                    XC_Interference_risk__c : res.Interference,
                    XC_Specific_Risk__c : res.SpecificRisk,
                    XC_Other_Specific_risks__c : res.OtherRisk,
                    XC_Communication_electrical_hazards__c : res.CommHazards,
                    XC_Enel_Activity_Multi__c : res.EnelActivityMulti,
                    XC_Documents_provided_company_Multi__c : res.DocumentMulti,
                    XC_Other_documentation__c : res.OtherDocument,
                    XC_Other_requirements_A3_4__c : res.OtherReq3_4,
                    XC_Other_requirements_A5_1__c : res.OtherReq5_1,
                    XC_Further_measures__c : res.FurtherMeasure,
                    XC_Further_measures_notes__c : res.FurtherMeasureNotes,
                    XC_Further_measures_pohibited_equipment__c : res.FurtherProhibited,
                    XC_Measurements_int_with_prohibited__c : res.MeasurementProhibited,
                    XC_Measures_to_eliminate_interference__c : res.MeasurementInterference,
                    XC_Any_reports_notes__c : res.AnyReportNotes,
                    XC_Place_works_will_take__c : res.FirstAidMeasure,
                    XC_Other_first_aid_site__c : res.OtherFirstAid,
                    XC_Technician_following_contract__c : res.TechnicianContract,
                    XC_Technician_Phone__c : res.TechnicianPhone,
                    XC_Other_principals__c : res.OtherPricipals,
                    XC_Contractor_Company_Statement__c : res.ContractorStatement,
                    XC_Building_contractors__c : res.BuildingContractors,
                    XC_DocumentTemplateLabel__c : res.TemplateLabel,
                    XC_WorkOrderLineItem__c : component.get("v.recordId")
                    };
                console.log("Test " + component.get("v.recordId")) ;
                var createRecordEvent = $A.get('e.force:createRecord');
                var windowHash = window.location.hash;
                if ( createRecordEvent ) {
                    createRecordEvent.setParams({
                        'entityApiName': 'Document_Template__c',
                        "panelOnDestroyCallback": function(event) {
                            window.location.hash = windowHash;
                        },
                        "navigationLocation":"LOOKUP",
                        'defaultFieldValues': prepopulate
                    });
                    createRecordEvent.fire();
                   // component.set("v.recordId","Is it geting there");
                } else {
                    /* Create Record Event is not supported */
                    alert("Account creation not supported");
                }
            }
        });
        $A.enqueueAction(action);
    },

    RetrieveTemplateId : function(component, event, helper){
        let action = component.get("c.NewTemplateId");
        console.log("Third " + component.get("v.Templatechoice")) ;
        action.setParams({
             recordId: component.get("v.recordId")
        })
        action.setCallback(this,function(response){
            
            let state = response.getState();
            let res = response.getReturnValue();
            
            if (state === "SUCCESS" && res != null) {
                component.set("v.Templatechoice","res") ;
            }
    });
    $A.enqueueAction(action);
}
})
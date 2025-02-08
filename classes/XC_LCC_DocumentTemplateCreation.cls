public without sharing class XC_LCC_DocumentTemplateCreation {

   public class WOLIWrapper{

        @AuraEnabled
        public String AccountZone{get;set;}

        @AuraEnabled
        public String InteralId{get;set;}

        @AuraEnabled
        public String WorkOrder{get;set;}

        @AuraEnabled
        public String ContractNumber{get;set;}

        @AuraEnabled
        public String ContractSAP{get;set;}

        @AuraEnabled
        public String AccountName{get;set;}

        @AuraEnabled
        public String WoliAccountName{get;set;}

        @AuraEnabled
        public String Description{get;set;}

        @AuraEnabled
        public String Workslgs{get;set;}

        @AuraEnabled
        public String NumberCompany{get;set;}
        @AuraEnabled
        public String EntitiesDay{get;set;}
        @AuraEnabled
        public String Interference{get;set;}
        @AuraEnabled
        public String SpecificRisk{get;set;}
        @AuraEnabled
        public String OtherRisk{get;set;}
        @AuraEnabled
        public String CommHazards{get;set;}
        @AuraEnabled
        public String EnelActivityMulti{get;set;}
        @AuraEnabled
        public String DocumentMulti{get;set;}
        @AuraEnabled
        public String OtherDocument{get;set;}
        @AuraEnabled
        public String OtherReq3_4{get;set;}
        @AuraEnabled
        public String OtherReq5_1{get;set;}
        @AuraEnabled
        public String FurtherMeasure{get;set;}
        @AuraEnabled
        public String FurtherMeasureNotes{get;set;}

        @AuraEnabled
        public String FurtherProhibited{get;set;}
        @AuraEnabled
        public String FurtherProhibitedNotes{get;set;}
        @AuraEnabled
        public String MeasurementProhibited{get;set;}
        @AuraEnabled
        public String MeasurementProhibitedNotes{get;set;}
        @AuraEnabled
        public String MeasurementInterference{get;set;}
        @AuraEnabled
        public String MeasurementInterferenceNotes{get;set;}
        @AuraEnabled
        public String AnyReportNotes{get;set;}
        @AuraEnabled
        public String FirstAidMeasure{get;set;}
        @AuraEnabled
        public String OtherFirstAid{get;set;}
        @AuraEnabled
        public String TechnicianContract{get;set;}
        @AuraEnabled
        public String TechnicianPhone{get;set;}
        @AuraEnabled
        public String PlaceWorks{get;set;}
        @AuraEnabled
        public String OtherPricipals{get;set;}
        @AuraEnabled
        public String ContractorStatement{get;set;}
        @AuraEnabled
        public String BuildingContractors{get;set;}
        @AuraEnabled
        public String TemplateLabel{get;set;}

        @AuraEnabled
        public String AccountMainPhone{get;set;}

        @AuraEnabled
        public String Subcontractor{get;set;}
        
        @AuraEnabled
        public String RecordType{get;set;}


  }
 
    @AuraEnabled
    public static WOLIWrapper PopulatefieldsfromWOLI(String recordId){
        System.debug('Propulate %' );
        WorkOrderLineItem woli = [select Id, RecordType.DeveloperName, WorkOrder.XC_Opportunity__r.XC_Zone__c, XC_InternalID__c, WorkOrderId, XC_ContractId__c, XC_ContractId__r.XC_ContractSAP__c, XC_AccountId__c, WorkOrder.AccountId, Description, XC_AccountId__r.XC_AccountMainPhone__c, XC_SubcontractorCompany__c  from WorkOrderLineItem  WHERE id =: recordId ];

        WOLIWrapper ResultWrap = new WOLIWrapper();
        
        ResultWrap.RecordType = Schema.SObjectType.Document_Template__c.getRecordTypeInfosByName().get('ModArt26').getRecordTypeId() ;
        
        if(woli.WorkOrder.XC_Opportunity__r.XC_Zone__c != null)
            ResultWrap.AccountZone = woli.WorkOrder.XC_Opportunity__r.XC_Zone__c ;
        else
            ResultWrap.AccountZone = null ;

        if(woli.XC_InternalID__c != null)
            ResultWrap.InteralId = woli.XC_InternalID__c ;
        else
            ResultWrap.InteralId = null ;

        if(woli.WorkOrderId != null)
            ResultWrap.WorkOrder = woli.WorkOrderId ;
        else
            ResultWrap.WorkOrder = null ;

        if(woli.XC_ContractId__c != null)
            ResultWrap.ContractNumber = woli.XC_ContractId__c ;
        else
            ResultWrap.ContractNumber = null ;

        if(woli.XC_ContractId__r.XC_ContractSAP__c != null)
            ResultWrap.ContractSAP = woli.XC_ContractId__r.XC_ContractSAP__c ;
        else
            ResultWrap.ContractSAP = null ;

        if(woli.XC_AccountId__c != null)
            ResultWrap.AccountName = woli.XC_AccountId__c ;
        else
            ResultWrap.AccountName = null ;

        if(woli.WorkOrder.AccountId != null)
            ResultWrap.WoliAccountName = woli.WorkOrder.AccountId;
        else
            ResultWrap.WoliAccountName = null ;

        if(woli.Description != null)
            ResultWrap.Description = woli.Description ;
        else
            ResultWrap.Description = null ;

        if(woli.XC_AccountId__r.XC_AccountMainPhone__c != null)
            ResultWrap.AccountMainPhone = woli.XC_AccountId__r.XC_AccountMainPhone__c ;
        else
            ResultWrap.AccountMainPhone = null ;

        if(woli.XC_SubcontractorCompany__c != null)
            ResultWrap.Subcontractor = woli.XC_SubcontractorCompany__c ;
        else
            ResultWrap.Subcontractor = null ;

        return ResultWrap;
    }

    @AuraEnabled
    public static WOLIWrapper ClonefieldsfromTemplate(String recordId, String Template){
        System.debug('Clonefiels' );
        
        Document_Template__c temp = [ Select XC_Zone__c, XC_InternalID__c, XC_WorkOrder__c, XC_ContractNumber__c, XC_ContractSAP__c, 
        XC_Partner__c, XC_AccountId__c, XC_Description__c, XC_Works_Lgs_81_08__c, XC_Number_contracting_companies__c,
        XC_Entities_man_days__c, XC_Interference_risk__c, XC_Specific_Risk__c, XC_Other_Specific_risks__c, 
        XC_Communication_electrical_hazards__c, XC_Enel_Activity_Multi__c, XC_Documents_provided_company_Multi__c,
        XC_Other_documentation__c, XC_AccountMainPhone__c, XC_Other_requirements_A3_4__c, XC_Other_requirements_A5_1__c,
        XC_Further_measures__c, XC_Further_measures_notes__c, XC_Further_measures_pohibited_equipment__c, XC_Further_meas_poh_eqip_Notes__c,
        XC_Measurements_int_with_prohibited__c, XC_Meas_int_with_prohib_Notes__c, XC_Meas_to_elim_interf_Notes__c,
        XC_Measures_to_eliminate_interference__c, XC_Any_reports_notes__c, XC_Place_works_will_take__c,
        XC_Other_first_aid_site__c, XC_Technician_following_contract__c, XC_Technician_Phone__c, XC_Place_worksInstal_will_take__c,
        XC_Other_principals__c, XC_Contractor_Company_Statement__c, XC_Building_contractors__c, XC_SubcontratorCompany__c, XC_DocumentTemplateLabel__c FROM Document_Template__c  WHERE Id =: Template ];

        WorkOrderLineItem woli = [select Id, RecordType.DeveloperName, WorkOrder.XC_Opportunity__r.XC_Zone__c, XC_InternalID__c, WorkOrderId, XC_ContractId__c, XC_ContractId__r.XC_ContractSAP__c, XC_AccountId__c, WorkOrder.AccountId, Description, XC_AccountId__r.XC_AccountMainPhone__c, XC_SubcontractorCompany__c  from WorkOrderLineItem  WHERE id =: recordId ];

        WOLIWrapper ResultWrap = new WOLIWrapper();
        
         ResultWrap.RecordType = Schema.SObjectType.Document_Template__c.getRecordTypeInfosByName().get('ModArt26').getRecordTypeId() ;

        if(temp.XC_Zone__c != null)
            ResultWrap.AccountZone = woli.WorkOrder.XC_Opportunity__r.XC_Zone__c ;
        else
            ResultWrap.AccountZone = null ;

        if(temp.XC_InternalID__c != null)
            ResultWrap.InteralId = woli.XC_InternalID__c ;
        else
            ResultWrap.InteralId = null ;

        if(temp.XC_WorkOrder__c != null)
            ResultWrap.WorkOrder = woli.WorkOrderId ;
        else
            ResultWrap.WorkOrder = null ;

        if(temp.XC_ContractNumber__c != null)
            ResultWrap.ContractNumber = woli.XC_ContractId__c ;
        else
            ResultWrap.ContractNumber = null ;

        if(temp.XC_ContractSAP__c != null)
            ResultWrap.ContractSAP = woli.XC_ContractId__r.XC_ContractSAP__c ;
        else
            ResultWrap.ContractSAP = null ;

        if(temp.XC_Partner__c != null)
            ResultWrap.AccountName = woli.XC_AccountId__c ;
        else
            ResultWrap.AccountName = null ;

        if(temp.XC_AccountId__c != null)
            ResultWrap.WoliAccountName = woli.WorkOrder.AccountId;
        else
            ResultWrap.WoliAccountName = null ;

        if(temp.XC_Description__c != null)
            ResultWrap.Description = woli.Description ;
        else
            ResultWrap.Description = null ;

        if(temp.XC_Works_Lgs_81_08__c != null)
            ResultWrap.Workslgs = temp.XC_Works_Lgs_81_08__c ;
        else
            ResultWrap.Workslgs = null ;

        if(temp.XC_Number_contracting_companies__c != null)
            ResultWrap.NumberCompany = temp.XC_Number_contracting_companies__c ;
        else
            ResultWrap.NumberCompany = null ;

        if(temp.XC_Entities_man_days__c != null)
            ResultWrap.EntitiesDay = temp.XC_Entities_man_days__c ;
        else
            ResultWrap.EntitiesDay = null ;

        if(temp.XC_Interference_risk__c != null)
            ResultWrap.Interference = temp.XC_Interference_risk__c ;
        else
            ResultWrap.Interference = null ;

        if(temp.XC_Specific_Risk__c != null)
            ResultWrap.SpecificRisk = temp.XC_Specific_Risk__c ;
        else
            ResultWrap.SpecificRisk = null ;

        if(temp.XC_Other_Specific_risks__c != null)
            ResultWrap.OtherRisk = temp.XC_Other_Specific_risks__c ;
        else
            ResultWrap.OtherRisk = null ;

        if(temp.XC_Communication_electrical_hazards__c != null)
            ResultWrap.CommHazards = temp.XC_Communication_electrical_hazards__c ;
        else
            ResultWrap.CommHazards = null ;

        if(temp.XC_Enel_Activity_Multi__c != null)
            ResultWrap.EnelActivityMulti = temp.XC_Enel_Activity_Multi__c ;
        else
            ResultWrap.EnelActivityMulti = null ;

        if(temp.XC_Documents_provided_company_Multi__c != null)
            ResultWrap.DocumentMulti = temp.XC_Documents_provided_company_Multi__c;
        else
            ResultWrap.DocumentMulti = null ;

        if(temp.XC_Other_documentation__c != null)
            ResultWrap.OtherDocument = temp.XC_Other_documentation__c ;
        else
            ResultWrap.OtherDocument = null ;

        if(temp.XC_AccountMainPhone__c != null)
            ResultWrap.AccountMainPhone = woli.XC_AccountId__r.XC_AccountMainPhone__c ;
        else
            ResultWrap.AccountMainPhone = null ;

        if(temp.XC_Other_requirements_A3_4__c != null)
            ResultWrap.OtherReq3_4 = temp.XC_Other_requirements_A3_4__c ;
        else
            ResultWrap.OtherReq3_4 = null ;

        if(temp.XC_Other_requirements_A5_1__c != null)
            ResultWrap.OtherReq5_1 = temp.XC_Other_requirements_A5_1__c ;
        else
            ResultWrap.OtherReq5_1 = null ;

        if(temp.XC_Further_measures__c != null)
            ResultWrap.FurtherMeasure = temp.XC_Further_measures__c ;
        else
            ResultWrap.FurtherMeasure = null ;

        if(temp.XC_Further_measures_notes__c != null)
            ResultWrap.FurtherMeasureNotes = temp.XC_Further_measures_notes__c ;
        else
            ResultWrap.FurtherMeasureNotes = null ;

        if(temp.XC_Further_measures_pohibited_equipment__c != null)
            ResultWrap.FurtherProhibited = temp.XC_Further_measures_pohibited_equipment__c ;
        else
            ResultWrap.FurtherProhibited = null ;

        if(temp.XC_Further_meas_poh_eqip_Notes__c != null)
            ResultWrap.FurtherProhibitedNotes = temp.XC_Further_meas_poh_eqip_Notes__c ;
        else
            ResultWrap.FurtherProhibitedNotes = null ;

        if(temp.XC_Measurements_int_with_prohibited__c != null)
            ResultWrap.MeasurementProhibited = temp.XC_Measurements_int_with_prohibited__c ;
        else
            ResultWrap.MeasurementProhibited = null ;

        if(temp.XC_Meas_int_with_prohib_Notes__c != null)
            ResultWrap.MeasurementProhibitedNotes = temp.XC_Meas_int_with_prohib_Notes__c ;
        else
            ResultWrap.MeasurementProhibitedNotes = null ;

        if(temp.XC_Measures_to_eliminate_interference__c != null)
            ResultWrap.MeasurementInterference = temp.XC_Measures_to_eliminate_interference__c ;
        else
            ResultWrap.MeasurementInterference = null ;

        if(temp.XC_Meas_to_elim_interf_Notes__c != null)
            ResultWrap.MeasurementInterferenceNotes = temp.XC_Meas_to_elim_interf_Notes__c ;
        else
            ResultWrap.MeasurementInterferenceNotes = null ;

        if(temp.XC_Any_reports_notes__c != null)
            ResultWrap.AnyReportNotes = temp.XC_Any_reports_notes__c ;
        else
            ResultWrap.AnyReportNotes = null ;

        if(temp.XC_Place_worksInstal_will_take__c != null)
            ResultWrap.FirstAidMeasure = temp.XC_Place_worksInstal_will_take__c ;
        else
            ResultWrap.FirstAidMeasure = null ;

        if(temp.XC_Other_first_aid_site__c != null)
            ResultWrap.OtherFirstAid = temp.XC_Other_first_aid_site__c ;
        else
            ResultWrap.OtherFirstAid = null ;

        if(temp.XC_Technician_following_contract__c != null)
            ResultWrap.TechnicianContract = temp.XC_Technician_following_contract__c ;
        else
            ResultWrap.TechnicianContract = null ;

        if(temp.XC_Technician_Phone__c != null)
            ResultWrap.TechnicianPhone = temp.XC_Technician_Phone__c ;
        else
            ResultWrap.TechnicianPhone = null ;

        if(temp.XC_Place_works_will_take__c != null)
            ResultWrap.PlaceWorks = temp.XC_Place_works_will_take__c ;
        else
            ResultWrap.PlaceWorks = null ;

        if(temp.XC_Other_principals__c != null)
            ResultWrap.OtherPricipals = temp.XC_Other_principals__c ;
        else
            ResultWrap.OtherPricipals = null ;

        if(temp.XC_Contractor_Company_Statement__c != null)
            ResultWrap.ContractorStatement = temp.XC_Contractor_Company_Statement__c ;
        else
            ResultWrap.ContractorStatement = null ;

        if(temp.XC_Building_contractors__c != null)
            ResultWrap.BuildingContractors = temp.XC_Building_contractors__c ;
        else
            ResultWrap.BuildingContractors = null ;

        if(temp.XC_DocumentTemplateLabel__c != null)
            ResultWrap.TemplateLabel = temp.XC_DocumentTemplateLabel__c ;
        else
            ResultWrap.TemplateLabel = null ;

        if(temp.XC_SubcontratorCompany__c != null)
            ResultWrap.Subcontractor = woli.XC_SubcontractorCompany__c ;
        else
            ResultWrap.Subcontractor = null ;
        

        System.debug('Result = '+ ResultWrap) ;
        return ResultWrap;
    }

    @AuraEnabled
    public static String NewTemplateId(String recordId){
        Document_Template__c doc = [Select id from Document_Template__c where XC_WorkOrderLineItem__c =: recordId order by createddate desc Limit 1];
        System.debug('Result = '+ doc) ;
        return doc.id ;
    }

}
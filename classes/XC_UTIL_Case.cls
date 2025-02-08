/**
* @author Marco Rosa - marco.rosa@nttdata.com & Nicolò Leonardi - nleonardi@deloitte.it
* @date Creation 25/10/2018
* @date Modification dd/mm/yyyy
* @description XC_UTIL_Case – Util class for Case methods
*/ 

public without sharing class XC_UTIL_Case {   

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Case');

    /** @description CaseREST Wrapper */
    public class CaseRESTWrapper { 
        public String CallerType; //cr 733 vdb 24-06-2022
        public String LegalEntity;
        public String CaseID;
        public String CaseNumber;
        public String UniqueID;
        public String AccountID;
        public String ContactID;
        public String Reason;
        public String CaseReason;
        public String CaseSubCause;
        public String CaseSubType;
        public String CaseType;
        public String Channel;
        public String Country;
        public String Province;
        public String Priority;
        public String CreatedDate;
        public String ClosedDate;
        public String Owner;
        public String Status;
        public String ProductCategory;
        public String Description;
        public String PresentationMedium;
        public String LastCaseComment;
        public String WorkOrderID;
        public String ParentCaseID;
        public String OpportunityID;
        public String OrderID;
        public String AssetID;
        public String ContactPhone;
        public String NotificationEmail;
        public String ContactPreferredTime;
        public String Subject;
        public Integer CounterOfInsistences;
        public String TypeOfIntermediary;
        public String OrderItemID;
        public String AddressID;
        public String AssetName;
        public String CaseCreationDate;
        public String CaseClosureDate;
        public String LastComment;
        public String Result;
        public String Brand;
        public String EngineCode;
        public String Class_x;
        public String SubscriptionID;
        public String SubStatus;
        public String ReceivingChannel;
        public String ChannelAttribute;
        public String ContactMobile;
        public String ContactEmail; 
        public String Resolution;
        public String CaseRemarks;
        public String CaseResult;
        public String Remarks;
        public Integer EnergyVasContractNumberOfDays;
        public Integer EnergyContractedPower;
        public String InvoiceID;
        public String ZuoraInvoiceID;
        public String GeolocalizationCountry; 
        
        public String AccountDNI;
        public String ContractNumber;

        public Boolean SkipAccountContact;
        public String FileBase64Name;
        public String FileBase64;
        public String FaultType;
        public String DefectType;
        public String DefectDescription;
        public string TechnicalAssetId;
        public String Segment; 
        public String BusinessLine ;
        public String TechnicalAsset;
        public String ContactName;
        public String ContactSurname;
        public String CompanyName;
        public String IsCloned; 
		public string AddressTA;
        public string RecordTypeId;
        public string ReportedByName;
        public string Origin;
        public string SerialNumber;        
        //[ BEGIN, deepti.ramesh@accenture.com, 21/2/2022, R1-2022, AO011249, added new tag]
        public Decimal InstallationCost;
        public Decimal PermittingCost;
        public String Design;
        //[ END, deepti.ramesh@accenture.com, 21/2/2022, R1-2022, AO011249, added new tag]
        //Lead Outbound
        public String TargetDate;
        public Boolean IsViolated;
        public String SuspensionDate;
        public String NotesForSuspensionAndResolution;
        public String ReasonForSuspension;
        public String NotesForResolution;

        // NR2059 - Eleni Tsiolaki - 30/11/2021 - Added the XC_eCityProductArea__c field
        public String eCityProductArea;

        public List<MilestoneWrapper> Milestone;
        //[ BEGIN, neeraj.saini@accenture.com, 11/4/2022, CTI integration, added new tag]
        public String ProtocolNumber;
        public String OwnerID;
        public String RequestJourney;
        //[ END, neeraj.saini@accenture.com, 11/4/2022, CTI integration, added new tag]
    }

    //Milestone 
    public class MilestoneWrapper { 
        public string MilestoneID;
        public string MilestoneTypeName;
        public DateTime StartDate;
        public DateTime TargetDate;
        public DateTime CompletionDate;
        public Boolean IsCompleted; 
        public Boolean IsViolated;
    }


    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @description Init a Case Object from a specific XC_CM_Case_Type_Setting__mdt and return it.
     * @param caseSettings - XC_CM_Case_Type_Setting__mdt
     * @return Case
     */
    public static Case initCaseFromCaseSettings(XC_CM_Case_Type_Setting__mdt caseSettings){
        Case caseObj = new Case();
        //Id recordTypeId = CaseDAO.newInstance().getActiveRecordtypeIdByDeveloperName(XC_AT_Constants.CASE_RECORD_TYPE_XC_ATTENTION_ESPANA);
        //caseObj.RecordTypeId = recordTypeId;
        caseObj = populateCaseFromCaseSettings(caseSettings);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ initCaseFromCaseSettings - new caseObj='+caseObj);
        return caseObj;
    }

    /**
     * @description Populate Case from Case settings
     * @param caseSettings - XC_CM_Case_Type_Setting__mdt
     * @return Case
     */
    private static Case populateCaseFromCaseSettings(XC_CM_Case_Type_Setting__mdt caseSettings) {
        Case caseObj = new Case();
        if(caseSettings!=null){
            caseObj.Reason = caseSettings.XC_Case_Reason__c;
            caseObj.SubCause__c = caseSettings.XC_Sub_Cause__c;
            caseObj.XC_Subtype__c = caseSettings.XC_Sub_Type__c;
            caseObj.Origin = caseSettings.XC_Origin__c;
            if(caseSettings.XC_Status__c != null){
                caseObj.Status = caseSettings.XC_Status__c;
            }else{
                caseObj.Status = Label.XC_CL_Case_Open;
            }
            caseObj.Priority = caseSettings.XC_Priority__c;
        }
        return caseObj;
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com - Chiara Turco - cturco@deloitte.it
     * @description Chech if newCase match with settings in input.
     * @param newCase - Case
     * @param settings - XC_CM_Case_Type_Setting__mdt
     * @return Boolean
     */
    public static Boolean matchSettings(Case newCase, XC_CM_Case_Type_Setting__mdt settings){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ matchSettings - settings='+settings);
        return  ((newCase.Reason!=null && newCase.Reason.equals(settings.XC_Case_Reason__c)) &&
                (newCase.Subcause__c!=null && newCase.Subcause__c.equals(settings.XC_Sub_Cause__c)) &&
                (settings.XC_Sub_Type__c == null || (settings.XC_Sub_Type__c.equals(newCase.XC_Subtype__c))));
    }
    
    /**
     * @description Retrieve related WorkOrder
     * @param cases - List<Case>
     * @return Map<Id,WorkOrder>
     */
    public static Map<Id,WorkOrder> retriveRelatedWO(List<Case> cases){
        Set<Id> woIds = XC_UTIL_Sobject.getSetIdsOnField(cases, 'XC_WorkOrder__c');
        Map<Id,WorkOrder> result = new Map<Id, WorkOrder>([SELECT Id, AccountId, ContactId, AssetId, City, Country, PostalCode, Street, State FROM WorkOrder WHERE Id IN: woIds]);
        return result;
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @description retrive record from XC_CM_Case_Type_Setting__mdt by the typeNames in input
     * @param typeNames - List<String>
     * @return Map<String, XC_CM_Case_Type_Setting__mdt> with key typeName and value XC_CM_Case_Type_Setting__mdt
     */
    public static Map<String, XC_CM_Case_Type_Setting__mdt> retriveCaseTypeSettings(List<String> typeNames){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ retriveCaseTypeSettings for typeNames='+typeNames);
        if(!Schema.sObjectType.XC_CM_Case_Type_Setting__mdt.isAccessible()){
            return new Map<String, XC_CM_Case_Type_Setting__mdt>();
        }
        List<XC_CM_Case_Type_Setting__mdt> caseTypeSettingsMtd = [SELECT id, DeveloperName,XC_Resolution__c, XC_Case_Reason__c, XC_Sub_Cause__c, XC_Sub_Type__c, XC_Priority__c, 
                                                                    XC_Origin__c, XC_Status__c, XC_Result__c, XC_CaseRemarks__c, XC_CaseRemarksEnelXItalia__c
                                                                    FROM XC_CM_Case_Type_Setting__mdt 
                                                                   WHERE DeveloperName IN: typeNames];
        
        Map<String,XC_CM_Case_Type_Setting__mdt> settingsMap = new Map<String,XC_CM_Case_Type_Setting__mdt>();
        for(XC_CM_Case_Type_Setting__mdt mtd : caseTypeSettingsMtd){
            settingsMap.put(mtd.DeveloperName, mtd);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ retriveCaseTypeSettings result='+settingsMap);
        return settingsMap;
    }

    /**
    * START PAYMENT VERIFICATION
    **/
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com, Giovanni Schioppa - giovanni.schioppa@nttdata.com
     * @description Method to create a List of Compliance Verification Cases related to Orders.
     * @param listOrderItems - List<NE__OrderItem__c>
    **/
    public static void createPaymentVerificationCases(List<NE__OrderItem__c> listOrderItems){ 
        XC_UTIL_Case_U_CreateCase.createPaymentVerificationCases(listOrderItems);      
    } 

    /**
     * @description Create Payment Verification Case
     * @param ordItem - NE__OrderItem__c
     * @return Case
    **/
    public static Case createPaymentVerificationCase(NE__OrderItem__c ordItem){
        return XC_UTIL_Case_U_CreateCase.createPaymentVerificationCase(ordItem);
    } 

    /**
    * END PAYMENT VERIFICATION
    **/

    /**
    * START NOTIFICATION CUSTOMER
    **/ 
    /**
     * @description Create Reservation Case
     * @param listConfItem - List<NE__OrderItem__c>
     * @param mapConfItemrResult - Map<String, String>
    **/
    public static void createCaseReservationKO(List<NE__OrderItem__c> listConfItem, Map<String,String> mapConfItemrResult) {
        XC_UTIL_Case_U_CreateCase.createCaseReservationKO(listConfItem, mapConfItemrResult);
    }       

    /**
     * @description Create Reservation Case
     * @param ordItem - NE__OrderItem__c
     * @return Case
    **/
    public static Case createCaseReservationKO(NE__OrderItem__c ordItem){
        return XC_UTIL_Case_U_CreateCase.createCaseReservationKO(ordItem); 
    } 
    /**
    * END NOTIFICATION CUSTOMER
    **/

    /**
    * START COMPLIANCE CASE
    **/ 
   /**
     * @author Giovanni Schioppa - giovanni.schioppa@nttdata.com / Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to create a List of Compliance Cases related to Orders when a compliance document is required.
     * @param mapConfItemComplianceMaster
     * @param mapConfItemComplianceWrapper
    **/
    public static void createComplianceCases(Map<Id, List<String>> mapConfItemComplianceMaster, Map<Id, XC_UTIL_ComplianceMaster.ComplianceWrapperResult> mapConfItemComplianceWrapper){ 
             XC_UTIL_Case_U_CreateCase.createComplianceCases(mapConfItemComplianceMaster, mapConfItemComplianceWrapper);
    }
    /**
    * END START COMPLIANCE CASE
    **/

    /**
    * START ADMINISTRATIVE TASK CASE
    **/ 
   /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to create a List of Administrative Tasks Cases from an invocable class invoked by a flow.
     * @param ordItem - NE__OrderItem__c
     * @return List<Case>
    **/
    public static List<Case> createAdministrativeCase(NE__OrderItem__c ordItem, XC_Provisioning_Step__c step, XC_CM_Case_Type_Setting__mdt caseMDT){
        return XC_UTIL_Case_U_CreateCase.createAdministrativeCase(ordItem, step, caseMDT);
    }
    /**
    * END ADMINISTRATIVE TASK CASE 
    **/ 

    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description Method to create an administrative case
    **/
    /*public static Case createAdministrativeCase(Id orderId, Id queueId, String administrativeTasks){
        Case c = new Case();
        String descriptionToAdd = Label.XC_CL_Administrative_Tasks_Required;

        //c.OwnerId = queueId;
        c.XC_Order__c = orderId;
        c.Reason = XC_AT_Constants.TRIGGER_REASON_MOT006;
        c.SubCause__c  = XC_AT_Constants.TRIGGER_SUBCAUSE_ATCL028;
        c.Status = XC_AT_Constants.TRIGGER_STATUS_ESTA001;
        c.Type = Label.XC_CL_Administrative_Tasks;
        c.Priority = '1';
        c.Description = Label.XC_CL_Administrative_Tasks_Required;
        c.Subject = Label.XC_CL_Administrative_Tasks;
        List<String> splittedTasks = (administrativeTasks).split(';');  
        c.Description = String.join(splittedTasks, ', ');  
        return c;
    } */
    
    /**
    * @author Giulio Serra giserra@deloitte.it
    * @description create Wrapper from Case
    * @param c - Case
    * @return CaseRESTWrapper
    */
    public static CaseRESTWrapper createWrapperFromCase(Case c) {
        CaseRESTWrapper wrapper = new CaseRESTWrapper();
        wrapper.CaseID = c.ID;
        wrapper.CaseNumber = c.CaseNumber;
        wrapper.UniqueID = c.Account.XC_UniqueId__c;
        wrapper.AccountID = c.AccountID;
        wrapper.ContactID = c.ContactID;
        wrapper.CaseReason = c.Reason;
        wrapper.CaseSubCause = c.SubCause__c;
        wrapper.CaseSubType = c.XC_Subtype__c;
        wrapper.Channel = c.Origin;
        wrapper.Country = c.Country__c;
        wrapper.Priority = c.Priority;
        wrapper.CreatedDate = String.valueOf(c.CreatedDate);
        wrapper.ClosedDate = String.valueOf(c.ClosedDate);
        wrapper.Owner = c.OwnerId;
        wrapper.Status = c.Status;
        wrapper.SubStatus = c.XC_SubStatus__c;
        wrapper.CaseResult = c.XC_Result__c;
        wrapper.ContactPhone = c.XC_ContactPhone__c;
        wrapper.ContactMobile = c.ContactMobile;
        wrapper.ContactEmail = c.XC_ContactEmail__c;
        wrapper.NotificationEmail = c.NotificationEmail__c;
        wrapper.ContactPreferredTime = c.XC_Contact_Preferred_Time__c;
        wrapper.ProductCategory = c.XC_ProductCategoryOfInterest__c;
        wrapper.Subject = c.Subject;
        wrapper.Description = c.Description;
        wrapper.CounterOfInsistences = Integer.valueOf(c.XC_ReclamationCounter__c);
        wrapper.TypeOfIntermediary = c.XC_Type_Intermediary__c;
        wrapper.PresentationMedium = c.Type_Notification__c;
        wrapper.WorkOrderID = c.XC_WorkOrder__c;
        wrapper.ParentCaseID = c.ParentId;
        wrapper.OpportunityID = c.XC_Opportunity__c;
        wrapper.OrderID = c.XC_Order__c;
        wrapper.OrderItemID = c.XC_OrderItem__c;
        wrapper.AddressID = c.XC_Address__c;
        wrapper.AssetID = c.AssetId;
        wrapper.AssetName = c.Asset.Name;
        // wrapper.ContractID = 
        wrapper.Brand = c.Asset.NE__CatalogItem__r.XC_Brand__c;
        wrapper.EngineCode = c.Asset.NE__CatalogItem__r.NE__Engine_Code__c;
        wrapper.ReceivingChannel = c.XC_Receiving_Channel__c;
        wrapper.ChannelAttribute = c.XC_Channel_Attribute__c;
        wrapper.Resolution = c.XC_Resolution__c;
        wrapper.CaseRemarks = c.CaseRemarks__c;
        Wrapper.InvoiceID = c.XC_Invoice__C;
        wrapper.GeolocalizationCountry = c.XC_GeolocalizationCountry__c;
        wrapper.TechnicalAssetID = c.XC_TechnicalAsset__c;
        // NR2059 - Eleni Tsiolaki - 30/11/2021 - Added the XC_eCityProductArea__c field
        //[ BEGIN, deepti.ramesh@accenture.com, 21/2/2022, R1-2022, AO011249, added mapping for new tag]
        wrapper.InstallationCost = c.XC_InstallationCost__c;
        wrapper.PermittingCost = c.XC_PermittingCost__c;
        wrapper.Design = c.XC_Design__c;
        //[ END, deepti.ramesh@accenture.com, 21/2/2022, R1-2022, AO011249, added mapping for new tag]
        wrapper.eCityProductArea = c.XC_eCityProductArea__c;
        //[ BEGIN, neeraj.saini@accenture.com, 11/4/2022, CTI integration, added mapping for new tag]
        wrapper.ProtocolNumber = c.XC_ProtocolNumber__c;
        wrapper.OwnerID = c.OwnerId;
        wrapper.RequestJourney  = c.XC_RequestJourney__c;
        //[ END, neeraj.saini@accenture.com, 11/4/2022, CTI integration, added mapping for new tag]
        if(!c.CaseMilestones.isEmpty()){
            wrapper.Milestone = new List<MilestoneWrapper>();
            for(CaseMilestone m: c.CaseMilestones){
                MilestoneWrapper mw = new MilestoneWrapper();
                mw.MilestoneID = m.Id; 
                mw.MilestoneTypeName = m.MilestoneType.Name; 
                mw.StartDate = m.StartDate; 
                mw.TargetDate = m.TargetDate; 
                mw.CompletionDate = m.CompletionDate; 
                mw.IsCompleted = m.IsCompleted; 
                mw.IsViolated = m.IsViolated;
                wrapper.Milestone.add(mw);
            }
        }

        return wrapper;
    }

    /**
    * @author Giulio Serra giserra@deloitte.it
    * @description create Wrapper from Case
    * @param c - Case
    * @param comments - List<CaseComment>
    * @return CaseRESTWrapper
    */
    public static CaseRESTWrapper createWrapperFromCase(Case c, List<CaseComment> comments) {
        CaseRESTWrapper wrapper = createWrapperFromCase(c);

        if(!comments.isEmpty()) {
            wrapper.LastCaseComment = comments[0].CommentBody;
        }

        return wrapper;
    }

    /**
    * @author Giulio Serra giserra@deloitte.it
    * @description create Wrapper from Case
    * @param wrapper - XC_UTIL_Case.CaseRESTWrapper
    * @param accountID - String
    * @param contactID - String
    * @return Case
    */
    public static Case createCaseFromWrapper(XC_UTIL_Case.CaseRESTWrapper wrapper, String accountID, String contactID) {
        Case c = new Case();
        if(String.isNotBlank(wrapper.CaseID)) {
            c.Id = wrapper.CaseID;
        }

        Map<String, Object> mapCaseWrapper = new Map<String,Object>{
            'XC_CallerType__c'=> wrapper.CallerType, //cr 733 vdb 24-06-2022
            'XC_LegalEntity__c' => (wrapper.LegalEntity=='Endesa Energía SAU' || (String.isNotBlank(wrapper.LegalEntity) && wrapper.LegalEntity.equalsIgnoreCase('Endesa X Servicios SL')))? 'EndesaX':wrapper.LegalEntity,
            'Reason' => wrapper.CaseReason,
            'SubCause__c' => wrapper.CaseSubCause,
            'XC_Subtype__c' => wrapper.CaseSubType,
            'XC_OriginChannel__c' => wrapper.Channel,
            'Country__c' => wrapper.Country,
            'Priority' => wrapper.Priority,
            'ClosedDate' => wrapper.ClosedDate,
            'Status' => wrapper.Status,
            'ContactPhone__c' => wrapper.ContactPhone,
            'NotificationEmail__c' => wrapper.NotificationEmail,
            'XC_Contact_Preferred_Time__c' => wrapper.ContactPreferredTime,
            'XC_ProductCategoryOfInterest__c' => wrapper.ProductCategory,
            'Subject' => wrapper.Subject,
            'Description' => wrapper.Description,
            'XC_ReclamationCounter__c' => wrapper.CounterOfInsistences,
            'XC_Type_Intermediary__c' => wrapper.TypeOfIntermediary,
            'Type_Notification__c' => wrapper.PresentationMedium,
            'XC_Result__c' => wrapper.Result,
            'XC_Resolution__c' => wrapper.Resolution,
            'CaseRemarks__c' => wrapper.Remarks,
            'XC_Invoice__c' => wrapper.InvoiceID,
            'XC_EnergyVasContractNumberOfDays__c' => wrapper.EnergyVasContractNumberOfDays, 
            'XC_EnergyContractedPower__c' => wrapper.EnergyContractedPower,
            'Origin' => (wrapper.Channel == 'App eMobility') ? Label.XC_CL_Case_Origin_AppEmobility : ((wrapper.Channel == 'Market') ? Label.XC_CL_Case_Origin_Market : wrapper.Channel),
            'XC_GeolocalizationCountry__c' => wrapper.GeolocalizationCountry,
            'XC_Segment__c' => (String.isBlank(wrapper.Segment)&&String.isBlank(wrapper.AccountID)&&String.isBlank(wrapper.ContactID)) ? 'B2C' : wrapper.Segment,
            'XC_FaultType__c' => wrapper.FaultType,
            'XC_DefectDescription__c' => wrapper.DefectDescription,

            'XC_DefectType__c' => wrapper.DefectType,
            'XC_Segment__c' => (String.isBlank(wrapper.Segment)&&String.isBlank(wrapper.AccountID)&&String.isBlank(wrapper.ContactID)) ? 'B2C' : wrapper.Segment,
            'XC_SerialNumber__c' => wrapper.SerialNumber,
            'XC_BusinessLine__c' => wrapper.BusinessLine,
            'XC_NeedInternalCheck__c' => ((wrapper.LegalEntity == 'EnelXMSP' || wrapper.LegalEntity == 'EnelXMobilityHolding') && wrapper.Channel == 'App eMobility') ? true : null, 
            'XC_eCityProductArea__c' => wrapper.eCityProductArea,
            'OwnerId' => wrapper.OwnerID,
            'XC_ProtocolNumber__c' => wrapper.ProtocolNumber,
            'XC_RequestJourney__c' => wrapper.RequestJourney
        };

        for(String key : mapCaseWrapper.keySet()){
            if(mapCaseWrapper.get(key) != null){
                c.put(key, mapCaseWrapper.get(key));
            }
        }


        Map<String, Object> mapCaseWrapperB2B = new Map<String,Object>{ 

            'XC_TechnicalAsset__c' => wrapper.TechnicalAsset,
            'XC_ContactPhone__c' => wrapper.ContactPhone,
            'XC_ContactEmail__c' => wrapper.ContactEmail,
            'XC_ContactName__c' => wrapper.ContactName,
            'XC_ContactSurname__c' => wrapper.ContactSurname,
            'XC_CompanyName__c' => wrapper.CompanyName,
            'XC_IsCloned__c' => wrapper.IsCloned!=null?Boolean.valueOf(wrapper.IsCloned):null
            
        };

        if(wrapper.Segment=='B2B'||wrapper.Segment=='B2G'){
            for(String key : mapCaseWrapperB2B.keySet()){
                if(mapCaseWrapperB2B.get(key) != null){
                    c.put(key, mapCaseWrapperB2B.get(key));
                }
            }
        }

        XC_UTIL_Case_U.PopulateCaseWrapper populateCaseWrapper = new XC_UTIL_Case_U.PopulateCaseWrapper();
        populateCaseWrapper.c = c;
        populateCaseWrapper.wrapper = wrapper;
        populateCaseWrapper.accountID = accountID;
        populateCaseWrapper.contactID = contactID;
        XC_UTIL_Case_U.populateCase(populateCaseWrapper);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Case populated ---> ' + populateCaseWrapper.c);
        return populateCaseWrapper.c;
    }

    /**
    * @description method for update Case Parent Status: inProgress if all sons have the same Owner, else InPending  
    * @param tasks  - List<Task>
    * @param mapOld
    * @param mapNew
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @modify 30/04/2019 - Monica Cutillo - monica.cutillo@nttdata.com (fix)
    **/
    public static void manageCasePendingTask(List<Task> tasks,Map<Id,Task> mapOld, Map<Id,Task> mapNew) {
        XC_UTIL_Case_U_ManageCase.manageCasePendingTask(tasks, mapOld, mapNew);
    }

    /**
    * @description Manage Case Pending from Related Case
    * @param cases - List<Case>
    * @param mapOld
    * @param mapNew
    * @modify 30/04/2019 - Monica Cutillo - monica.cutillo@nttdata.com (fix)
    **/
    public static void manageCasePendingFromRelatedCase(List<Case> cases,Map<Id,Case> mapOld, Map<Id,Case> mapNew) {
        XC_UTIL_Case_U_ManageCase.manageCasePendingFromRelatedCase(cases, mapOld, mapNew);
    }

    public static void manageCasePendingConf(List<NE__Order__c> listNew,Map<Id,NE__Order__c> mapOld, Map<Id,NE__Order__c> mapNew){
        XC_UTIL_Case_U_ManageCase.manageCasePendingConf(listNew,mapOld,mapNew);
    }

    public static void manageCasePendingOpp(List<Opportunity> listNew,Map<Id,Opportunity> mapOld, Map<Id,Opportunity> mapNew){
        XC_UTIL_Case_U_ManageCase.manageCasePendingOpp(listNew,mapOld,mapNew);
    }

    /**
    * @description Check if is Parent
    * @param tasks - List<Task>
    **/
    @TestVisible
    private static void isParentCasePendingTask(List<Task> tasks){
        XC_UTIL_Case_U_ManageCase.isParentCasePendingTask(tasks);
    }
    
    /**
    * @description Check if is Parent
    * @param cases - List<Case>
    **/
    @TestVisible
    private static void isParentCasePendingFromRelatedCase(List<Case> cases){
        XC_UTIL_Case_U_ManageCase.isParentCasePendingFromRelatedCase(cases);
    }
    
    /**
    * @description Check if is Parent
    * @param cases - List<NE__Order__c>
    **/
    @TestVisible
    private static void isParentCasePendingConf(List<NE__Order__c> conf){
        XC_UTIL_Case_U_ManageCase.isParentCasePendingConf(conf);
    }

    /**
     * @description Manage case status for related WO.
     * @param listNew the list new
     */
    public static void manageCaseStatusFromRelatedWO(List<WorkOrder> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'enter in manageCaseStatus FromRelated WO');
        Set<Id> caseIdsToPending = new Set<Id>();
        for(WorkOrder newWorkOrder : listNew){ 
            if (newWorkOrder.CaseId != null && newWorkOrder.Status != null){
                if(newWorkOrder.Status.equals(XC_AT_Constants.WO_STATUS_CANCELED) || newWorkOrder.Status.equals(Label.XC_CL_WorkOrder_Completed) || newWorkOrder.Status.equals(Label.XC_CL_CannotComplete)){
                    caseIdsToPending.add(newWorkOrder.CaseId);
                }
            }  
        } 
        if(!caseIdsToPending.isEmpty()){
            XC_UTIL_Case.isParentCasePending(caseIdsToPending); 
        }
    }
    
    /**
    * @description Check if is Parent
    * @param caseIds - Set<Id>
    **/
    @TestVisible
    private static void isParentCasePending(Set<Id> caseIds) {
        XC_UTIL_Case_U_Check.updateParentCaseStatus(caseIds);
    }

    /**
    * @description Get Related ParentCases
    * @param caseParentIds - Set<Id>
    * @return List<Case>
    **/
    public static List<Case> getRelatedParentCasesByCaseIds(Set<Id> caseParentIds){
        //Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_ESP_Case).getRecordTypeId();
        if(!Schema.sObjectType.Case.isAccessible()){
            return new List<Case>();
        }
        List<Case> caseLisOpen = [SELECT  Id, ParentId, Status , AssetId, OwnerId, Reason,Subcause__c,XC_LegalEntity__c,XC_Type_Intermediary__c, CaseRemarks__c, XC_Segment__c,XC_NeedInternalCheck__c FROM Case WHERE Id IN: caseParentIds]; // AND RecordTypeId =: recordTypeId
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'isRelatedObjectOpen , caseLisOpen ' + caseLisOpen);
        return caseLisOpen;
    }

    /**
    * @description Get Case Record Type
    * @param listNew List<Case> 
    * @return Map<String,String>
    **/
    public static Map<String,String> getCaseRecordType(List<Case> listNew){
        Map<String,String> reasonToRecordType = new Map<String,String>();
        List<String> reasonList = XC_UTIL_Sobject.getListFieldValues(listNew, 'Reason');
        Set<String> reasonSet  = new Set<String>(reasonList);
        List<String> legalEntityList = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_LegalEntity__c');
        Set<String> legalEntitySet  = new Set<String>(legalEntityList);
        List<String> streamList = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_Segment__c'); 
        Set<String> streamSet = new Set<String>(streamList);

        List<XC_CM_CaseReasonRtMapping__mdt> rtByReason = new List<XC_CM_CaseReasonRtMapping__mdt>();
        if(streamSet.isEmpty()) {
            rtByReason = [SELECT id, XC_CaseReason__c, XC_CaseRecordType__c, XC_LegalEntity__c 
                            FROM XC_CM_CaseReasonRtMapping__mdt 
                            WHERE XC_CaseReason__c IN: reasonSet AND XC_LegalEntity__c IN:legalEntitySet];
        } else {
            rtByReason = [SELECT id, XC_CaseReason__c, XC_CaseRecordType__c, XC_LegalEntity__c 
                            FROM XC_CM_CaseReasonRtMapping__mdt 
                            WHERE XC_CaseReason__c IN: reasonSet AND XC_LegalEntity__c IN:legalEntitySet AND XC_Stream__c IN: streamSet];
        }
        
        System.debug('@@@ RecordType By Reason ' +rtByReason);
        for(XC_CM_CaseReasonRtMapping__mdt cr : rtByReason ) {
            /*String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(cr.XC_CaseRecordType__c).getRecordTypeId();
            reasonToRecordType.put(cr.XC_CaseReason__c, recordTypeId);*/

            Schema.RecordTypeInfo rtInfo = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(cr.XC_CaseRecordType__c);
            if(rtInfo.isAvailable()) {
                reasonToRecordType.put(cr.XC_CaseReason__c, rtInfo.getRecordTypeId());
            }
        }
        return reasonToRecordType;
    } 

    /**
    * @description Get Case Record Type Families
    * @param listNew List<Case>
    * @return all info in Map<String,String>
    **/
    public static Map<String,String> getCaseRecordTypeFamily(List<Case> listNew){
        Map<String,String> reasonToRecordType = new Map<String,String>();
        List<XC_CM_CaseReasonRtMapping__mdt> rtByReason = XC_UTIL_Case_D.getCaseReasonRtMappingValues(listNew);
        
        for(XC_CM_CaseReasonRtMapping__mdt cr : rtByReason ){
            reasonToRecordType.put(cr.XC_CaseReason__c, cr.XC_RecordTypeFamily__c);
        }
        return reasonToRecordType;
    }

    /**
    * @description Get default Case Record Type
    * @param legalEntity
    * @return value result
    **/
    /*public static String getDefaultCaseRecordType(String legalEntity){
        System.debug('legalEntityFromUser = '+legalEntity);
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ESP_Case').getRecordTypeId();
        /*if(legalEntity == Label.XC_CL_EndesaX){
            return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ESP_Case').getRecordTypeId();
            
        }else if(legalEntity == Label.XC_CL_JuicenetLimited){
            return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_UK_Information_Case').getRecordTypeId();
        }else{
            return '';
        }* /
    }*/

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description Get default Case Record Type by case reason RT metadata
     * @param legalEntities
     * @param segments
     * @return values data map results
     **/
    public static Map<String,String> getDefaultCaseRecordTypeByMetadata(Set<String> legalEntities, Set<String> segments){
        Map<String,String> result = new Map<String,String>();
        result.put('master_default','XC_ESP_Case');
        //Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ESP_Case').getRecordTypeId()

        Map<Id,XC_CM_CaseReasonRtMapping__mdt> rtMtd = new Map<Id,XC_CM_CaseReasonRtMapping__mdt>([
            SELECT XC_CaseRecordType__c, XC_LegalEntity__c, XC_Stream__c
            FROM XC_CM_CaseReasonRtMapping__mdt 
            WHERE XC_LegalEntity__c IN: legalEntities
            AND XC_Stream__c IN: segments
            AND XC_RecordTypeFamily__c = 'Information'
        ]);
        for(XC_CM_CaseReasonRtMapping__mdt mtd: rtMtd.values()){
            result.put(mtd.XC_LegalEntity__c + mtd.XC_Stream__c, mtd.XC_CaseRecordType__c);
        }

        return result;
    }


}
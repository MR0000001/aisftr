/*
@CreatedBy      - Andrea Liverani (andrea.liverani@webresults.it), 2020/09/25 
@Description    - Class to mange the dynamic creation of each configurable component
@TestClass      - TA_LCC201_DynamicLayoutContainer_Test
*/

public without sharing class TA_LCC201_DynamicLayoutContainer {
    public TA_LCC201_DynamicLayoutContainer() {}

    public class InfoBag {
        @AuraEnabled
        public Map<String, Map<String, String>> generalInfoMap  {get; set;}
        @AuraEnabled
        public List<SectionWrapper>             sectionWrappers {get; set;}
    }

    public class GeneralInfoWrapper {
        @AuraEnabled
        public String   field   {get; set;}
        @AuraEnabled
        public String   value   {get; set;}

        public GeneralInfoWrapper(String field, String value) {
            this.field = field;
            this.value = value;
        }
    }

    public class SectionWrapper {
        @AuraEnabled
        public String               cmpName {get; set;}
        @AuraEnabled
        public List<ParamWrapper>   params  {get; set;}

        public SectionWrapper(String cmpName, List<ParamWrapper> params) {
            this.cmpName = cmpName;
            this.params = params;
        }
    }

    public class ParamWrapper {
        @AuraEnabled
        public String   key     {get; set;}
        @AuraEnabled
        public Object   value   {get; set;}

        public ParamWrapper(String key, Object value) {
            this.key = key;
            this.value = value;
        }
    }

    @AuraEnabled
    public static InfoBag getConfigurations(Id workOrderId) {
        InfoBag infoBag = new InfoBag();
        infoBag.generalInfoMap = new Map<String, Map<String, String>>();
        infoBag.sectionWrappers = new List<SectionWrapper>();
        try {
            String currentUserPermissionSetName;
            if(Test.isRunningTest()){
                currentUserPermissionSetName = 'Italy_Set';
            } else {
                Id currentUserProfileId = UserInfo.getUserId();
                List<PermissionSetAssignment> currentUserPermissionSetList = [SELECT PermissionSet.Name
                                                                                FROM PermissionSetAssignment
                                                                                WHERE AssigneeId =: currentUserProfileId
                                                                                    AND PermissionSet.Description = 'TA_Configuration_Language'];

                if(!currentUserPermissionSetList.isEmpty()) {
                    currentUserPermissionSetName = currentUserPermissionSetList[0].PermissionSet.Name;
                }
            }

            WorkOrder workOrder = getWorkOrder(workOrderId);
            ServiceAppointment serviceAppointmentInProgress = getServiceAppointmentInProgress(workOrder);
            System.debug('@@@ serviceAppointmentInProgress> ' + serviceAppointmentInProgress);

            String userProfileName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1][0].Name; //ENCXRM-151 HSEQ BGO

            if(workOrder.Id != null) {
                 // List<TA_Capability_Configuration__c> cbConfigurations = [SELECT Id,
                //                                                             TA_DeveloperName__c,
                //                                                             TA_JSON_Param__c,
                //                                                             TA_Index__c,
                //                                                             TA_Value__c
                //                                                         FROM TA_Capability_Configuration__c
                //                                                         WHERE TA_Type__c =: 'Layout'
                //                                                             AND TA_Active__c = true
                //                                                             AND TA_WorkType_Category__c =: workOrder.XC_WorkTypeCategory__c
                //                                                             AND TA_Phase__r.TA_DeveloperName__c =: workOrder.TA_Phase__c
                //                                                             AND TA_Configuration_Set__c =: currentUserPermissionSetName
                //                                                         ORDER BY TA_Index__c ASC];

                String cbQuery = 'SELECT Id, TA_DeveloperName__c, TA_JSON_Param__c, TA_Index__c, TA_Value__c ' 
                                + 'FROM TA_Capability_Configuration__c ' 
                                + 'WHERE TA_Type__c = \'Layout\' ' 
                                + 'AND TA_Active__c = true '
                                + 'AND TA_WorkType_Category__c = \'' + workOrder.XC_WorkTypeCategory__c + '\' '
                                + 'AND TA_Phase__r.TA_DeveloperName__c = \'' + workOrder.TA_Phase__c + '\' '
                                + 'AND TA_Configuration_Set__c = \'' + currentUserPermissionSetName + '\' ';

                if( TA_CNS201_DynamicLayoutContainer.CB_HSEQ_PROFILE_LIST.contains(userProfileName) ) cbQuery += ' AND TA_ProfileName__c = \'' + userProfileName + '\' ';

                cbQuery += 'ORDER BY TA_Index__c ASC';

                System.debug('>_> cbQuery : ' + cbQuery);

                List<TA_Capability_Configuration__c> cbConfigurations = Database.query(cbQuery);
                System.debug('>_> cbConfigurations : ' + cbConfigurations);

                if(!cbConfigurations.isEmpty()) {

                    if(workOrder.XC_WorkTypeCategory__c == 'Delivery & Installation' && workOrder.ParentWorkOrderId == null){
                        cbConfigurations = setDeliveryInsConfiguration(workOrder, cbConfigurations);
                    }

                    for(TA_Capability_Configuration__c cbConfig : cbConfigurations) {
                        if(cbConfig.TA_DeveloperName__c == TA_CNS201_DynamicLayoutContainer.CB_MAPS) {
                            if ( (TA_CNS201_DynamicLayoutContainer.CB_HSEQ_PROFILE_LIST.contains(userProfileName) || Test.isRunningTest()) && workOrder.XC_Address__c != null) {
                                List<ParamWrapper> paramWraps = new List<ParamWrapper>();
                                paramWraps.add(new ParamWrapper('Longitude', workOrder.XC_Address__r.XC_Coordinates__Longitude__s != null ? workOrder.XC_Address__r.XC_Coordinates__Longitude__s : workOrder.Longitude));
                                paramWraps.add(new ParamWrapper('Latitude', workOrder.XC_Address__r.XC_Coordinates__Latitude__s != null ? workOrder.XC_Address__r.XC_Coordinates__Latitude__s : workOrder.Latitude));
                                paramWraps.add(new ParamWrapper('City', workOrder.XC_Address__r.XC_City__c));
                                paramWraps.add(new ParamWrapper('Street',  workOrder.XC_Address__r.XC_StreetTypeText__c + ' ' + workOrder.XC_Address__r.XC_Address__c + ' ' + workOrder.XC_Address__r.XC_StreetNumber__c));
                                paramWraps.add(new ParamWrapper('PostalCode', workOrder.XC_Address__r.XC_PostalCode__c));
                                paramWraps.add(new ParamWrapper('Country', workOrder.XC_Address__r.XC_AddressCountry__c));

                                infoBag.sectionWrappers.add(new SectionWrapper(cbConfig.TA_DeveloperName__c, paramWraps));
                            } else if(serviceAppointmentInProgress.Id != null) {
                                Address customerAddress = serviceAppointmentInProgress.Address;
                                List<ParamWrapper> paramWraps = new List<ParamWrapper>();

                                //START - [20220428AL] - NR2331 (Req. F)
                                //if(customerAddress != null) {
                                if(
                                    ( 
                                        String.isNotBlank(workOrder.AssetId) 
                                        && String.isNotBlank(workOrder.Asset.LocationId) 
                                        && workOrder.Asset.Location.Longitude != null
                                        && workOrder.Asset.Location.Latitude != null
                                    ) || customerAddress != null) {
                                    
                                    paramWraps.add(new ParamWrapper('Longitude', 
                                        String.isNotBlank(workOrder.AssetId) && 
                                        String.isNotBlank(workOrder.Asset.LocationId) &&
                                        workOrder.Asset.Location.Longitude != null
                                        ? workOrder.Asset.Location.Longitude
                                        : customerAddress.getLongitude()));

                                    paramWraps.add(new ParamWrapper('Latitude', 
                                        String.isNotBlank(workOrder.AssetId) && 
                                        String.isNotBlank(workOrder.Asset.LocationId) &&
                                        workOrder.Asset.Location.Latitude != null
                                        ? workOrder.Asset.Location.Latitude
                                        : customerAddress.getLatitude()));

                                    //paramWraps.add(new ParamWrapper('Longitude', customerAddress.getLongitude()));
                                    //paramWraps.add(new ParamWrapper('Latitude', customerAddress.getLatitude()));
                                    //END - [20220428AL] - NR2331 (Req. F)

                                    paramWraps.add(new ParamWrapper('City', customerAddress.getCity()));
                                    paramWraps.add(new ParamWrapper('Street', customerAddress.getStreet()));
                                    paramWraps.add(new ParamWrapper('PostalCode', customerAddress.getPostalCode()));
                                    paramWraps.add(new ParamWrapper('Country', customerAddress.getCountry()));
                                }
                                paramWraps.add(new ParamWrapper('contactName', serviceAppointmentInProgress.Contact.Name));

                                infoBag.sectionWrappers.add(new SectionWrapper(cbConfig.TA_DeveloperName__c, paramWraps));
                            } else {
                                System.debug('[TA_LCC201_DynamicLayoutContainer] getConfigurations - serviceAppointments is empty.');
                            }

                        } else if(cbConfig.TA_DeveloperName__c == TA_CNS201_DynamicLayoutContainer.CB_SECONDARY_CONTACT) {
                            List<ParamWrapper> paramWraps = new List<ParamWrapper>();
                            
                            paramWraps.add(new ParamWrapper('workOrder', workOrder));
                            paramWraps.add(new ParamWrapper('contactId', workOrder.ContactId));
                            paramWraps.add(new ParamWrapper('accountId', workOrder.AccountId));
                            paramWraps.add(new ParamWrapper('fieldSet', cbConfig.TA_JSON_Param__c));

                            infoBag.sectionWrappers.add(new SectionWrapper(cbConfig.TA_DeveloperName__c, paramWraps));
                        } else if(cbConfig.TA_DeveloperName__c == TA_CNS201_DynamicLayoutContainer.CB_DYNAMIC_TABLE) {
                            List<ParamWrapper> paramWraps = new List<ParamWrapper>();

                            paramWraps.add(new ParamWrapper('workOrderId', workOrderId));
                            paramWraps.add(new ParamWrapper('NE_orderId', workOrder.XC_Configuration__c));
                            paramWraps.add(new ParamWrapper('assetId', workOrder.AssetId));
                            paramWraps.add(new ParamWrapper('accountId', workOrder.AccountId));
                            paramWraps.add(new ParamWrapper('fieldSet', cbConfig.TA_JSON_Param__c));

                            infoBag.sectionWrappers.add(new SectionWrapper(cbConfig.TA_DeveloperName__c, paramWraps));
                        }else if(cbConfig.TA_DeveloperName__c == TA_CNS201_DynamicLayoutContainer.CB_DYNAMIC_MULTIQUERY) {
                            List<ParamWrapper> paramWraps = new List<ParamWrapper>();
                            
                            paramWraps.add(new ParamWrapper('workOrderId', workOrderId));
                            paramWraps.add(new ParamWrapper('assetId', workOrder.AssetId));
                            paramWraps.add(new ParamWrapper('accountId', workOrder.AccountId));
                            paramWraps.add(new ParamWrapper('fieldSet', cbConfig.TA_JSON_Param__c));
                            paramWraps.add(new ParamWrapper('cmpName', cbConfig.TA_DeveloperName__c));

                            infoBag.sectionWrappers.add(new SectionWrapper(cbConfig.TA_DeveloperName__c, paramWraps));
                        } else if(cbConfig.TA_DeveloperName__c == TA_CNS201_DynamicLayoutContainer.CB_REMIND) {
                            List<ParamWrapper> paramWraps = new List<ParamWrapper>();
                            
                            paramWraps.add(new ParamWrapper('workOrderId', workOrderId));
                            paramWraps.add(new ParamWrapper('workTypeCategory', workOrder.XC_WorkTypeCategory__c));
                            paramWraps.add(new ParamWrapper('language', UserInfo.getLanguage()));
                            paramWraps.add(new ParamWrapper('fieldSet', cbConfig.TA_JSON_Param__c));

                            infoBag.sectionWrappers.add(new SectionWrapper(cbConfig.TA_DeveloperName__c, paramWraps));
                        } else if(cbConfig.TA_DeveloperName__c == TA_CNS201_DynamicLayoutContainer.CB_AUTHORIZEDPROVIDERS ||
                        cbConfig.TA_DeveloperName__c == TA_CNS201_DynamicLayoutContainer.CB_CARTCONTAINER ||
                        cbConfig.TA_DeveloperName__c == TA_CNS201_DynamicLayoutContainer.CB_QUOTESUMMARY ||
                        cbConfig.TA_DeveloperName__c == TA_CNS201_DynamicLayoutContainer.CB_TAKE_PHOTO ||
                        cbConfig.TA_DeveloperName__c == TA_CNS201_DynamicLayoutContainer.CB_ORDERSUMMARY ||
                        cbConfig.TA_DeveloperName__c == TA_CNS201_DynamicLayoutContainer.CB_PAYMENTMETHOD) {
                            List<ParamWrapper> paramWraps = new List<ParamWrapper>();

                            paramWraps.add(new ParamWrapper('workOrder', workOrder));
                            paramWraps.add(new ParamWrapper('fieldSet', cbConfig.TA_JSON_Param__c));

                            infoBag.sectionWrappers.add(new SectionWrapper(cbConfig.TA_DeveloperName__c, paramWraps));
                        //JS - XINSAPP-526 - 14/04/2022 - START
                        //} else if(cbConfig.TA_DeveloperName__c == TA_CNS201_DynamicLayoutContainer.CB_REQUIREDDOCUMENT) {
                        } else if(cbConfig.TA_DeveloperName__c == TA_CNS201_DynamicLayoutContainer.CB_REQUIREDDOCUMENT || cbConfig.TA_DeveloperName__c == TA_CNS201_DynamicLayoutContainer.CB_PARTNERSKILLS) {
                        //JS - XINSAPP-526 - 14/04/2022 - END
                            List<ParamWrapper> paramWraps = new List<ParamWrapper>();
                            
                            paramWraps.add(new ParamWrapper('workOrderId', workOrderId));
                            paramWraps.add(new ParamWrapper('configurationId', workOrder.XC_Configuration__c));
                            paramWraps.add(new ParamWrapper('fieldSet', cbConfig.TA_JSON_Param__c));
                            //JS - XINSAPP-525 - 14/04/2022 - START
                            paramWraps.add(new ParamWrapper('partnerId', workOrder.XC_AssignedPartner__c));
                            //JS - XINSAPP-525 - 14/04/2022 - END

                            infoBag.sectionWrappers.add(new SectionWrapper(cbConfig.TA_DeveloperName__c, paramWraps));
                        } else {
                            List<ParamWrapper> paramWraps = new List<ParamWrapper>();

                            paramWraps.add(new ParamWrapper('workOrderId', workOrderId));
                            paramWraps.add(new ParamWrapper('cmpName', cbConfig.TA_Value__c));
                            paramWraps.add(new ParamWrapper('fieldSet', cbConfig.TA_JSON_Param__c));

                            infoBag.sectionWrappers.add(new SectionWrapper(cbConfig.TA_DeveloperName__c, paramWraps));
                        }
                    }
                } else {
                    System.debug('[TA_LCC201_DynamicLayoutContainer] getConfigurations - no TA_Capability_Configuration__c founds.');
                }
            } else {
                System.debug('[TA_LCC201_DynamicLayoutContainer] getConfigurations - no WorkOrder found.');
            }
            infoBag.generalInfoMap = getGeneralInfo(workOrder, serviceAppointmentInProgress);
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();           
            System.debug('[TA_LCC201_DynamicLayoutContainer] getConfigurations - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC201_DynamicLayoutContainer', 'getConfigurations', errorMessage, 0, errorMessage, null);
        }
        return infoBag;
    }

    private static WorkOrder getWorkOrder(Id workOrderId) {
        WorkOrder workOrder = new WorkOrder();
        List<WorkOrder> workOrderList = [SELECT Id,
                                            AccountId,
                                            ContactId,
                                            Contact.Email,
                                            AssetId,
                                            //START - [20220428AL] - NR2331 (Req. F)
                                            Asset.LocationId,
                                            Asset.Location.Longitude,
                                            Asset.Location.Latitude,
                                            ParentWorkOrder.XC_WorkTypeCategory__c,
                                            //END - [20220428AL] - NR2331 (Req. F)
                                            Status,
                                            ParentWorkOrderId,
                                            XC_StatusReason__c,
                                            TA_Phase__c,
                                            XC_Configuration__c,
                                            XC_WorkTypeCategory__c,
                                            XC_AssignedPartner__c,
                                            XC_AssignedPartner__r.Name,
                                            XC_LegalEntity__c,
                                            XC_AssignedResource__c,
                                            XC_AssignedResource__r.Name,
                                            XC_Opportunity__c,
                                            XC_Opportunity__r.XC_PrincingRegion__c,
                                            TA_Parameters__c,
                                            XC_Lead__c,
                                            XC_WasteDisposal__c,
                                            XC_Address__c,
                                            XC_Address__r.Name,
                                            XC_Address__r.XC_City__c,
                                            XC_Address__r.XC_StreetTypeText__c,
                                            XC_Address__r.XC_Address__c,
                                            XC_Address__r.XC_StreetNumber__c,
                                            XC_Address__r.XC_PostalCode__c,
                                            XC_Address__r.XC_AddressCountry__c,
                                            XC_Address__r.XC_Coordinates__Latitude__s,
                                            XC_Address__r.XC_Coordinates__Longitude__s,
                                            Longitude, Latitude,
                                            (SELECT id FROM ChildWorkOrders)

                                        FROM WorkOrder
                                        WHERE Id = :workOrderId];

        if(!workOrderList.isEmpty()) {
            workOrder = workOrderList[0];
        }
        return workOrder;
    }

    /**
    * @description Check if wo with category Delivery&Installation has child and set the correct configurations 
    * @author benjamin.geronimo | 08-09-2021 
    * @param wo 
    * @param cbConfigurations 
    * @return List<TA_Capability_Configuration__c> 
    **/
    private static List<TA_Capability_Configuration__c> setDeliveryInsConfiguration(WorkOrder wo, List<TA_Capability_Configuration__c> cbConfigurations) {
        List<TA_Capability_Configuration__c> newDIConfigurations = new List<TA_Capability_Configuration__c>();
        Boolean woHasChild = false;

        if(wo.AssetId == null && !wo.ChildWorkOrders.isEmpty()) woHasChild = true;

        for(TA_Capability_Configuration__c cbConfig : cbConfigurations) {

            switch on cbConfig.TA_Value__c {
                when 'AssetInformation' {		
                    if(!woHasChild) newDIConfigurations.add(cbConfig);
                }	
                when 'WorkOrderChildInformation' {		
                    if(woHasChild) newDIConfigurations.add(cbConfig);
                }
                when 'Interventions' {		
                    if(!woHasChild) newDIConfigurations.add(cbConfig);
                }
                when 'TechnicalSheet' {		
                    if(!woHasChild) newDIConfigurations.add(cbConfig);
                }
                when 'ComponentTakePhoto' {		
                    if(!woHasChild) newDIConfigurations.add(cbConfig);
                }
                when 'WorkOrderInformation' {		
                    if(!woHasChild) newDIConfigurations.add(cbConfig);
                }
                when else {		  
                    newDIConfigurations.add(cbConfig);
                }
            }
        }

        return newDIConfigurations;

    }

    private static ServiceAppointment getServiceAppointmentInProgress(WorkOrder wo) {
        ServiceAppointment serviceAppointment = new ServiceAppointment();
        String queryString = 'SELECT Id, Address, ContactId, Contact.Name, Status, XC_StatusReason__c FROM ServiceAppointment';
        //START - [20220428AL] - NR2331 (Req. F)
        if(wo != null && String.isNotBlank(wo.ParentWorkOrderId) && wo.ParentWorkOrder.XC_WorkTypeCategory__c != 'Organizer') {
        //if(wo != null && String.isNotBlank(wo.ParentWorkOrderId)) {
        //END - [20220428AL] - NR2331 (Req. F)
            queryString += ' WHERE ParentRecordId = \'' + wo.ParentWorkOrderId + '\' AND Status != \'Canceled\''; //FIX [20220217AL]
        } else if(wo != null) {
            queryString += ' WHERE ParentRecordId = \'' + wo.Id + '\' AND Status != \'Canceled\''; //FIX [20220217AL]
        }
        
        System.debug('@@@ queryString> ' + queryString);
        List<ServiceAppointment> serviceAppointmentList = Database.query(queryString);

        if(!serviceAppointmentList.isEmpty()) {
            serviceAppointment = serviceAppointmentList[0];
        }
        return serviceAppointment;
    }

    @TestVisible
    private static Map<String, Map<String, String>> getGeneralInfo(WorkOrder workOrder, ServiceAppointment serviceAppointment) {
        Map<String, Map<String, String>> generalInfoMap = new Map<String, Map<String, String>>();
        try {
            Map<String, String> workOrderMap = new Map<String, String>();
            workOrderMap.put('Email', workOrder.Contact.Email);
            workOrderMap.put('LegalEntity', workOrder.XC_LegalEntity__c);
            workOrderMap.put('ServiceAppointmentID', serviceAppointment.Id);
            workOrderMap.put('AccountID', workOrder.AccountId);
            workOrderMap.put('WorkOrderID', workOrder.Id);
            workOrderMap.put('ContactID', workOrder.ContactId);
            workOrderMap.put('Status', workOrder.Status);
            workOrderMap.put('StatusReason', workOrder.XC_StatusReason__c);
            workOrderMap.put('ParentWorkOrderID', workOrder.ParentWorkOrderId);
            workOrderMap.put('OpportunityId', workOrder.XC_Opportunity__c);
            workOrderMap.put('LeadId', workOrder.XC_Lead__c);
            generalInfoMap.put('WorkOrder', workOrderMap);

            Map<String, String> serviceAppointmentMap = new Map<String, String>();
            serviceAppointmentMap.put('ServiceAppointmentID', serviceAppointment.Id);
            serviceAppointmentMap.put('Status', serviceAppointment.Status);
            serviceAppointmentMap.put('ActualStart', String.valueOf(Date.today()) + 'T' + String.valueOf(Datetime.now().timeGmt()));
            serviceAppointmentMap.put('ActualEnd', String.valueOf(Date.today()) + 'T' + String.valueOf(Datetime.now().timeGmt()));
            serviceAppointmentMap.put('StatusReason', serviceAppointment.XC_StatusReason__c);
            generalInfoMap.put('ServiceAppointment', serviceAppointmentMap);

            Map<String, String> opportunityMap = new Map<String, String>();
            opportunityMap.put('WorkOrderID', workOrder.Id);
            opportunityMap.put('AccountID', workOrder.AccountId);
            opportunityMap.put('PrincingRegion', workOrder.XC_Opportunity__r.XC_PrincingRegion__c);
            generalInfoMap.put('Opportunity', opportunityMap);
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();           
            System.debug('[TA_LCC201_DynamicLayoutContainer] getGeneralInfo - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC201_DynamicLayoutContainer', 'getGeneralInfo', errorMessage, 0, errorMessage, null);
        }
        return generalInfoMap;
    }
}
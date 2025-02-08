/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 05/05/2021
* @description XC_SC015_SendEmailToManager – Batch used to send email to Manager 
*/

public without sharing class XC_SC015_SendEmailToManager implements Database.Batchable<sObject>, Schedulable {

    public final static Boolean DEBUGACTIVE             = XC_UTIL_Debug.isActive('XC_SC015_SendEmailToManager');
    public final static Integer LIMITWO                 = 150;
    public final static Integer LIMITBODY               = 374000;
    public final static Integer LIMITSINGLEEMAIL        = 4000;
    /** @description BodyWrapper: wrapper to create table in HTML*/
    private class BodyWrapper {
        String woNumber = '';
        String orderNumber = '';
        String accountName = '';
        String productType = '';
        String woType = '';
        String woStatus = '';
        String shippingAddress = '';
        String mobilePhone = '';
        String schedStartDate = '';
        String action = '';
    }

    /** @description EmailWrapper: wrapper to select email address for sending report*/
    private class EmailWrapper {
        Boolean isUser = false;
        String idUser = '';
        String emailAddress = '';
    }

    /**
     * @description Method to schedule Batch
     * @param sc - SchedulableContext 
    */
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC015_SendEmailToManager(), 10);
    }  

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Start method for batch
     * @param bc - BatchableContext 
     * @return Database.getQueryLocator
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        if(!Schema.sObjectType.Account.isAccessible()) {
            return null;
        }
        return Database.getQueryLocator('SELECT Id, PrimaryEmail__c ' +
                                        'FROM Account ' +
                                        'WHERE IsPartner = true AND XC_GiveDataTo_EnelXItalia__c = true AND PrimaryEmail__c != null');
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Execute method for batch
     * @param bc - BatchableContext
     * @param scope - List<Account> 
    */
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        List<String> listStatusReason = new List<String>{Label.XC_CL_AssignedToTheTechnicianRescheduled, Label.XC_CL_StatusReason_Assignedtothetechnician, Label.XC_CL_StatusReason_ToBeScheduled};
        List<String> listWorkTypeToFilter = new List<String>{Label.XC_CL_WorkType_Repair, Label.XC_CL_WorkType_SiteInspection, Label.XC_CL_WorkType_DeliveryInstallation};
        List<WorkOrder> listWorkOrder = new List<WorkOrder>([
            SELECT Id, CreatedDate, Asset.XC_Original_Creation_Order_Lookup__r.Name, XC_Configuration__r.Name, XC_WorkTypeCategory__c, WorkOrderNumber, XC_Address__r.XC_City__c, PostalCode, XC_Address__r.XC_FullAddress__c, Contact.Name, XC_AssignedPartner__r.Name, XC_ProductSubType__c, XC_WorkTypeLabel__c, Status, Contact.Account.ShippingAddress, Contact.Phone, XC_StatusReason__c,ParentWorkOrderId, XC_Address__r.XC_Region__c,
                (SELECT Id, SchedStartTime, ActualEndTime 
                FROM ServiceAppointments 
                WHERE XC_IsFinalStatus__c = false)
            FROM WorkOrder
            WHERE XC_AssignedPartner__c IN :XC_UTIL_Sobject.getIds(scope) AND Status = :Label.XC_CL_WorkOrder_Assigned AND ParentWorkOrderId = null AND (XC_Configuration__r.XC_Status__c != :Label.XC_CL_Configuration_Cancelled OR XC_Configuration__c = null)
            AND (XC_LegalEntity__c =: Label.XC_CL_LegalEntity_Italy OR XC_LegalEntity__c =: Label.XC_CL_LegalEntity_EnelXMobilityItalia) AND XC_Segment__c = 'B2C'
            AND XC_StatusReason__c IN :listStatusReason
            AND XC_WorkTypeCategory__c IN :listWorkTypeToFilter
        ]);
        Map<String, String> woIdSubtypeMap = getChildrenWo(listWorkOrder);
        Map<String, List<WorkOrder>>    mapPartnerIdWorkOrder       = getOrderedMapWorkOrderPartner(listWorkOrder);
        Map<String, EmailWrapper>       mapPartnerIdEmail           = getMapPartnerEmail(scope, mapPartnerIdWorkOrder.keySet());
        sendEmail(mapPartnerIdWorkOrder, mapPartnerIdEmail, woIdSubtypeMap);
    }

    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date 06-01-2021 
    * @description Method to build Product Type cell
    * @param listWorkOrder - List<WorkOrder>
    * @return Map<String, String> 
    **/
    public static Map<String, String> getChildrenWo(List<WorkOrder> listWorkOrder){
        Map<String, Set<String>> woIdSubtypeSetMap = new Map<String, Set<String>>();
        Map<String, String> woIdSubtypeMap = new Map<String,String>();
        List<String> woIdsList = XC_UTIL_Sobject.getIds(listWorkOrder);
        List<WorkOrder> listWorkOrderChildren = new List<WorkOrder>([SELECT Id, XC_ProductSubType__c, ParentWorkOrderId FROM WorkOrder 
                                                                            WHERE ParentWorkOrderId IN: woIdsList AND XC_Configuration_Item__r.XC_Product_Type__c =: Label.XC_CL_ProductTypeEquipment
                                                                            AND XC_ProductSubType__c !=: '']);
        for(WorkOrder wo : listWorkOrderChildren){
            if(!woIdSubtypeSetMap.containsKey(wo.ParentWorkOrderId)) {
                woIdSubtypeSetMap.put(wo.ParentWorkOrderId, new Set<String>());
            }
            woIdSubtypeSetMap.get(wo.ParentWorkOrderId).add(wo.XC_ProductSubType__c);
        }
        for(String woId : woIdSubtypeSetMap.keySet()){
            String subtypes = '';
            Integer i = 1;
            for(String subtype : woIdSubtypeSetMap.get(woId)){
                subtypes += subtype;
                if(i < woIdSubtypeSetMap.get(woId).size()){
                    subtypes += ',';
                }
                i++;
            }
            woIdSubtypeMap.put(woId, subtypes);
        }
        return woIdSubtypeMap;
    }
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Finish method for batch
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'FINISH batch XC_SC015_SendEmailToManager'); 
    } 

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to build Map PartnerId->ListWo with limit and ordered
     * @param listWorkOrder - List<WorkOrder> 
     * @return Map<String, List<WorkOrder>>
    */
    public static Map<String, List<WorkOrder>> getOrderedMapWorkOrderPartner(List<WorkOrder> listWorkOrder) {
        Map<String, List<WorkOrder>> mapPartnerIdWorkOrder = new Map<String, List<WorkOrder>>();
        for(WorkOrder wo : listWorkOrder) {
            if(!mapPartnerIdWorkOrder.containsKey(wo.XC_AssignedPartner__c)) {
                List<WorkOrder> listWoForPartner = new List<WorkOrder>();
                listWoForPartner.add(wo);
                mapPartnerIdWorkOrder.put(wo.XC_AssignedPartner__c, listWoForPartner);
            } else if(mapPartnerIdWorkOrder.get(wo.XC_AssignedPartner__c).size() < LIMITWO) {
                mapPartnerIdWorkOrder.get(wo.XC_AssignedPartner__c).add(wo);
                if(mapPartnerIdWorkOrder.get(wo.XC_AssignedPartner__c).size() > 1) {
                    // Order current list:
                    List<WorkOrder> listWoToOrder = mapPartnerIdWorkOrder.get(wo.XC_AssignedPartner__c);
                    Integer sizeList = listWoToOrder.size();
                    if(listWoToOrder[sizeList-2].CreatedDate > listWoToOrder[sizeList-1].CreatedDate) {
                        WorkOrder woTemp = listWoToOrder[sizeList-2];
                        listWoToOrder[sizeList-2] = listWoToOrder[sizeList-1];
                        listWoToOrder[sizeList-1] = woTemp;
                    }
                    mapPartnerIdWorkOrder.put(wo.XC_AssignedPartner__c, listWoToOrder);
                } 
            }
        }
        return mapPartnerIdWorkOrder;
    }
    

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to send email to Manager
     * @param mapPartnerIdWorkOrder - Map<String, List<WorkOrder>>  
     * @param mapPartnerIdEmail - Map<String, EmailWrapper>
    */
    public static void sendEmail(Map<String, List<WorkOrder>> mapPartnerIdWorkOrder, Map<String, EmailWrapper> mapPartnerIdEmail, Map<String, String> woIdSubtypeMap) {
        // First, reserve email capacity for the current Apex transaction to ensure that we won't exceed our daily email limits when sending email after the current transaction is committed:
        Messaging.reserveMassEmailCapacity(mapPartnerIdWorkOrder.keySet().size());
        Map<String,System.OrgLimit> limitsMap = OrgLimits.getMap();
        System.OrgLimit apiRequestsLimit = limitsMap.get('SingleEmail');
        List<Messaging.SingleEmailMessage> listEmailToSend = new List<Messaging.SingleEmailMessage>();
        List<XC_CM_LegalEntity_Configuration__mdt> listLec = new List<XC_CM_LegalEntity_Configuration__mdt>([
            SELECT Id, XC_DisplayNameOrgWide__c
            FROM XC_CM_LegalEntity_Configuration__mdt 
            WHERE (XC_LegalEntity__c = :Label.XC_CL_LegalEntity_Italy OR XC_LegalEntity__c = :Label.XC_CL_LegalEntity_EnelXMobilityItalia) AND XC_OrgId__c = :UserInfo.getOrganizationId()
        ]);
        String idOrgWide = '';
        if(!listLec.isEmpty() && String.isNotBlank(listLec[0].XC_DisplayNameOrgWide__c)) {
            List<OrgwideEmailAddress> orgWideAddress = new List<OrgwideEmailAddress>([
                SELECT Id 
                FROM OrgwideEmailAddress
                WHERE DisplayName = :listLec[0].XC_DisplayNameOrgWide__c
            ]);
            if(!orgWideAddress.isEmpty() && String.isNotBlank(orgWideAddress[0].Id)) {
                idOrgWide = orgWideAddress[0].Id;
            }
        }
        List<User> listOfRegionalManagerAndBusinessOwner = new List<User>([SELECT Id, Email, XC_Region__c 
                                                                            FROM User 
                                                                            WHERE XC_RegionalManager_BusinessOwner__c =: true]);
        Map<String, List<Id>> mapRegionListOfIdUser = populateMapRegionListUserId(listOfRegionalManagerAndBusinessOwner);
        //query user -> n user con campo insieme delle regioni
        // mappa Regione - lista user
        // mapPartnerIdWorkOrder.get(manager Id) --> nuovo metodo (lista wo, mappa regione user) return lista id
        // lista id da mettere in cc

        for(String managerId : mapPartnerIdWorkOrder.keySet()) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            // Assign the addresses for the To list to the mail object:
            Boolean userFound = (mapPartnerIdEmail.containsKey(managerId) && mapPartnerIdEmail.get(managerId).isUser);
            if(userFound) {
                mail.setTargetObjectId(mapPartnerIdEmail.get(managerId).idUser);
                mail.setSaveAsActivity(false);
            } else {
                if(!mapPartnerIdEmail.containsKey(managerId)) continue;
                mail.setToAddresses(new List<String>{mapPartnerIdEmail.get(managerId).emailAddress});
            } 
            if(apiRequestsLimit.getValue() <= LIMITSINGLEEMAIL){
                mail.setCcAddresses(setRegionalManagerOrBusinessOwner(mapPartnerIdWorkOrder.get(managerId),mapRegionListOfIdUser));
            }      
            // Specify the subject line for your email address:
            mail.setSubject('Summary Work Order');            
            // Optionally append the salesforce.com email signature to the email (The email address of the user executing the Apex Code will be used):
            mail.setUseSignature(false);            
            // Specify the text content of the email:            
            mail.setHtmlBody(createBodyEmail(mapPartnerIdWorkOrder.get(managerId), woIdSubtypeMap));
            // Set from email by OrgWide (if exists):
            if(String.isNotBlank(idOrgWide)) {
                mail.setOrgWideEmailAddressId(idOrgWide); 
            } else {
                // Specify the name used as the display name:
                mail.setSenderDisplayName('Partner notifications');
            }
            listEmailToSend.add(mail);
        }

        // Send the email you have created:
        Messaging.sendEmail(listEmailToSend);
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to create body for email
     * @param listWo - List<WorkOrder>
     * @return String
    */
    public static String createBodyEmail(List<WorkOrder> listWo, Map<String, String> woIdSubtypeMap) {
        List<BodyWrapper> listBodyWrapper = createWrapperWorkOrder(listWo, woIdSubtypeMap);

        String body =   '<p>' + Label.XC_CL_EmailNotification1 + '</p>' +
                        '<table style="width: 100%; border-collapse: collapse; border: 1px solid rgb(0, 0, 0);">' +
                            '<tbody>' +
                                '<tr style="width: 100%; background-color: rgb(69, 32, 127) !important; color: rgb(255, 255, 255) !important; border-collapse: collapse;">' +
                                    '<td style="width: 6.3428%; border-collapse: collapse; border: 1px solid rgb(0, 0, 0);">' +
                                        '<div style="text-align: center;"><strong>' + Label.XC_CL_WorkOrder + '</strong></div>' +
                                    '</td>' +
                                    '<td style="width: 6.3428%; border-collapse: collapse; border: 1px solid rgb(0, 0, 0);">' +
                                        '<div style="text-align: center;"><strong>' + 'OR' + '</strong></div>' +
                                    '</td>' +
                                    '<td style="width: 13.978%; border-collapse: collapse; border: 1px solid rgb(0, 0, 0);">' +
                                        '<div style="text-align: center;"><strong>' + Label.XC_CL_CPAB_AccName + '</strong></div>' +
                                    '</td>' +
                                    '<td style="width: 16.3696%; border-collapse: collapse; border: 1px solid rgb(0, 0, 0);">' +
                                        '<div style="text-align: center;"><strong>' + Label.XC_CL_ProductType + '</strong></div>' +
                                    '</td>' +
                                    '<td style="width: 13.4581%; border-collapse: collapse; border: 1px solid rgb(0, 0, 0);">' +
                                        '<div style="text-align: center;"><strong>' + Label.XC_CL_Type + '</strong></div>' +
                                    '</td>' +
                                    '<td style="width: 12.0321%; border-collapse: collapse; border: 1px solid rgb(0, 0, 0);">' +
                                        '<div style="text-align: center;"><strong>' + Label.XC_CL_Status + '</strong></div>' +
                                    '</td>' +
                                    '<td style="width: 16.8449%; border-collapse: collapse; border: 1px solid rgb(0, 0, 0);">' +
                                        '<div style="text-align: center;"><strong>' + Label.XC_CL_Shipping_Address + '</strong></div>' +
                                    '</td>' +
                                    '<td style="width: 4.0107%; border-collapse: collapse; border: 1px solid rgb(0, 0, 0);">' +
                                        '<div style="text-align: center;"><strong>' + Label.XC_CL_Contact_Phone + '</strong></div>' +
                                    '</td>' +
                                    '<td style="width: 11.1111%; border-collapse: collapse; border: 1px solid rgb(0, 0, 0);">' +
                                        '<div style="text-align: center;"><strong>' + Label.XC_CL_AppointmentDate + '</strong></div>' +
                                    '</td>' +
                                    '<td style="width: 11.1111%; border-collapse: collapse; border: 1px solid rgb(0, 0, 0);">' +
                                        '<div style="text-align: center;"><strong>' + Label.XC_CL_Action + '</strong></div>' +
                                    '</td>' +
                                '</tr>';

        for(BodyWrapper bw : listBodyWrapper) {    
            String newLine =    '<tr style="border-collapse: collapse; border: 1px solid rgb(0, 0, 0);">' +
                                    '<td style="width: 6.3428%; border-collapse: collapse; border: 1px solid rgb(0, 0, 0);">'  + bw.woNumber           + '</td>' +
                                    '<td style="width: 13.978%; border-collapse: collapse; border: 1px solid rgb(0, 0, 0);">'  + bw.orderNumber        + '</td>' +
                                    '<td style="width: 13.978%; border-collapse: collapse; border: 1px solid rgb(0, 0, 0);">'  + bw.accountName        + '</td>' +
                                    '<td style="width: 16.3696%; border-collapse: collapse; border: 1px solid rgb(0, 0, 0);">' + bw.productType        + '</td>' +
                                    '<td style="width: 13.4581%; border-collapse: collapse; border: 1px solid rgb(0, 0, 0);">' + bw.woType             + '</td>' +
                                    '<td style="width: 12.0321%; border-collapse: collapse; border: 1px solid rgb(0, 0, 0);">' + bw.woStatus           + '</td>' +
                                    '<td style="width: 16.8449%; border-collapse: collapse; border: 1px solid rgb(0, 0, 0);">' + bw.shippingAddress    + '</td>' +
                                    '<td style="width: 4.0107%; border-collapse: collapse; border: 1px solid rgb(0, 0, 0);">'  + bw.mobilePhone        + '</td>' +
                                    '<td style="width: 11.1111%; border-collapse: collapse; border: 1px solid rgb(0, 0, 0);">' + bw.schedStartDate     + '</td>' +
                                    '<td style="width: 11.1111%; border-collapse: collapse; border: 1px solid rgb(0, 0, 0);">' + bw.action             + '</td>' +
                                '</tr>';
            if(body.split('').size()+newLine.split('').size()  <  LIMITBODY) {
                body += newLine;
            } else {
                break;
            }
        }

        body +=         '</tbody>' +
                    '</table>' +
                '<p>' + Label.XC_CL_EmailNotification2 + '</p>';

        return body;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to create a list of wrapper to create table of WorkOrder
     * @param listWo - List<WorkOrder>
     * @return List<BodyWrapper>
    */
    public static List<BodyWrapper> createWrapperWorkOrder(List<WorkOrder> listWo, Map<String, String> woIdSubtypeMap) {
        List<BodyWrapper> listBodyWrapper = new List<BodyWrapper>();
        for(WorkOrder wo : listWo) {
            System.debug('@@@SC015 Check WO: '+ wo);
            BodyWrapper bw = new BodyWrapper();
            bw.woNumber = wo.WorkOrderNumber;
            bw.orderNumber = String.isNotBlank(wo.XC_Configuration__r.Name) ? wo.XC_Configuration__r.Name : (String.isNotBlank(wo.Asset.XC_Original_Creation_Order_Lookup__r.Name) ? wo.Asset.XC_Original_Creation_Order_Lookup__r.Name : '');
            bw.accountName = String.isNotBlank(wo.Contact.Name) ? wo.Contact.Name : '';
            if(String.isNotBlank(wo.XC_ProductSubType__c)){
                bw.productType = wo.XC_ProductSubType__c;
            } else if(woIdSubtypeMap.containsKey(wo.Id)){
                bw.productType = woIdSubtypeMap.get(wo.Id);
            }
            //bw.productType = String.isNotBlank(wo.XC_ProductSubType__c) ? wo.XC_ProductSubType__c : if(woIdSubtypeMap.containsKey(wo.Id) {woIdSubtypeMap.get(wo.Id)} );
            bw.woType = String.isNotBlank(wo.XC_WorkTypeLabel__c) ? wo.XC_WorkTypeLabel__c : '';
            bw.woStatus = String.isNotBlank(wo.XC_StatusReason__c) ? wo.XC_StatusReason__c : '';
            bw.mobilePhone = String.isNotBlank(wo.Contact.Phone) ? wo.Contact.Phone : '';
            // For Address:
            String address = String.isNotBlank(wo.XC_Address__r.XC_FullAddress__c) ? 
                                        (String.isNotBlank(wo.PostalCode) && String.isNotBlank(wo.XC_Address__r.XC_City__c) ? wo.XC_Address__r.XC_FullAddress__c+','+wo.XC_Address__r.XC_City__c+','+wo.PostalCode : wo.XC_Address__r.XC_FullAddress__c)  : '';
            bw.shippingAddress = address;
            // For Appointment Date and Action:
            if(wo.XC_StatusReason__c == Label.XC_CL_StatusReason_Assignedtothetechnician && !wo.ServiceAppointments.isEmpty() && wo.ServiceAppointments[0].SchedStartTime != null) {
                Date onlyDate = Date.newinstance(wo.ServiceAppointments[0].SchedStartTime.year(), wo.ServiceAppointments[0].SchedStartTime.month(), wo.ServiceAppointments[0].SchedStartTime.day());
                bw.schedStartDate = String.isNotBlank(String.valueOf(onlyDate)) ? String.valueOf(onlyDate) : '';
            }
            bw.action = getAction(wo);
            listBodyWrapper.add(bw);
        }
        return listBodyWrapper;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to create a list of wrapper to create table of WorkOrder
     * @param wo - WorkOrder
     * @return String
    */
    public static String getAction(WorkOrder wo) {
        String action = '';
        Date schedulateDate;
        Date actualEndDate;
        ServiceAppointment sa = new ServiceAppointment();
        if(!wo.ServiceAppointments.isEmpty()){
            sa = wo.ServiceAppointments[0];
            if(sa.SchedStartTime != null){
                schedulateDate = Date.newinstance(sa.SchedStartTime.year(), sa.SchedStartTime.month(), sa.SchedStartTime.day());
            }
            if(sa.ActualEndTime != null){
                actualEndDate = Date.newinstance(sa.ActualEndTime.year(), sa.ActualEndTime.month(), sa.ActualEndTime.day());
            }
        } 
        Date today = Date.today();
        if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation && wo.XC_StatusReason__c == Label.XC_CL_StatusReason_Assignedtothetechnician && actualEndDate != null ){
            action = Label.XC_CL_ActionPartnerNotification_LoadDocsAndCloseWO;
        } else if(wo.XC_StatusReason__c == Label.XC_CL_StatusReason_ToBeScheduled){
            action = Label.XC_CL_ActionPartnerNotification_ScheduleAppointment;
        } else if(wo.XC_StatusReason__c == Label.XC_CL_StatusReason_Assignedtothetechnician && schedulateDate != null && schedulateDate < today){
            action = Label.XC_CL_ActionPartnerNotification_WaitUrgentlyPerformIntervention;
        } else if(wo.XC_StatusReason__c == Label.XC_CL_StatusReason_Assignedtothetechnician && schedulateDate != null && schedulateDate >= today && schedulateDate < today.addDays(14)){
            action = Label.XC_CL_ActionPartnerNotification_NoActionAppointmentScheduled;
        } else if(wo.XC_StatusReason__c == Label.XC_CL_StatusReason_Assignedtothetechnician && schedulateDate != null && schedulateDate >= today.addDays(14)) {
            action = Label.XC_CL_ActionPartnerNotification_AnticipateAppointmentToTheCurrentWeek;
        }
        return action;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to create a Map PartnerId -> Email address
     * @param listPartnerItaly - List<Account>
     * @param setAccountId - Set<String>
     * @return Map<String, EmailWrapper> 
    */
    public static Map<String, EmailWrapper> getMapPartnerEmail(List<Account> listPartnerItaly, Set<String> setAccountId) {
        Map<String, EmailWrapper> mapResult = new Map<String, EmailWrapper>();

        // Query users for Account Partner:
        List<User> listUser = new List<User>([
            SELECT Id, Email, AccountId
            FROM User
            WHERE AccountId IN :setAccountId
        ]);

        // Check if a Partner has one only user and populate map for multiple Users for Partner:
        Map<String, List<User>> mapAccountListUserTemp = new Map<String, List<User>>();
        Map<String, List<User>> mapAccountListUser = new Map<String, List<User>>();
        for(User us : listUser) {
            if(!mapAccountListUserTemp.containsKey(us.AccountId)) {
                mapAccountListUserTemp.put(us.AccountId, new List<User>());
            }
            mapAccountListUserTemp.get(us.AccountId).add(us);
        }
        for(String key : mapAccountListUserTemp.keySet()) {
            List<User> listCurrentUsers = mapAccountListUserTemp.get(key);
            mapAccountListUser.put(key, listCurrentUsers);
            /*if(listCurrentUsers.size() == 1) {
                EmailWrapper emWr = new EmailWrapper();
                emWr.isUser = true;
                emWr.idUser = listCurrentUsers[0].Id;
                mapResult.put(listCurrentUsers[0].AccountId, emWr);
            }*/
        }

        // Check and create result for Partner with multiple users:
        for(Account acc : listPartnerItaly) {
            if(!setAccountId.contains(acc.Id) || String.isBlank(acc.PrimaryEmail__c)) {
                continue;
            }
            String currentEmail = acc.PrimaryEmail__c;
            List<User> listUsersForAccount = mapAccountListUser.containsKey(acc.Id) ? mapAccountListUser.get(acc.Id) : new List<User>();
            String idUser = '';
            for(User us : listUsersForAccount) {
                if(currentEmail == us.Email) {
                    idUser = us.Id;
                    break;
                }                
            }
            if(String.isNotBlank(idUser)) {
                EmailWrapper emWr = new EmailWrapper();
                emWr.isUser = true;
                emWr.idUser = idUser;
                mapResult.put(acc.Id, emWr);
            } else {
                EmailWrapper emWr = new EmailWrapper();
                emWr.isUser = false;
                emWr.emailAddress = currentEmail;
                mapResult.put(acc.Id, emWr);
            }
        }
        return mapResult;
    }

    private static Map<String, List<Id>> populateMapRegionListUserId (List<User> listOfUser){
        Map<String, List<Id>> mapRegionListUserId = new Map<String, List<Id>>();
        for(User us : listOfUser){
            if(us.XC_Region__c != null){
                List<String> listOfRegion = us.XC_Region__c.split(';');
                for(String region : listOfRegion){
                    if(!mapRegionListUserId.containsKey(region)){
                        mapRegionListUserId.put(region.toUpperCase(), new List<Id>());
                    }
                    mapRegionListUserId.get(region.toUpperCase()).add(us.Id);
                }
            }
        }
        return mapRegionListUserId;
    }

    private static List<Id> setRegionalManagerOrBusinessOwner (List<WorkOrder> listOfWo, Map<String, List<Id>> mapRegionListOfIdUser){
        Set<Id> setOfUserId = new Set<Id>();
        for(WorkOrder wo : listOfWo){
            if(wo.XC_Address__r.XC_Region__c != null){
                String regionWo = wo.XC_Address__r.XC_Region__c.toUpperCase();
                if(regionWo.contains('EMILIA')){
                    regionWo = 'EMILIA-ROMAGNA';
                }else if (regionWo.contains('FRIULI')){
                    regionWo = 'FRIULI VENEZIA GIULIA';
                }else if (regionWo.contains('TRENTINO')){
                    regionWo = 'TRENTINO-ALTO ADIGE';
                }else if (regionWo.contains('AOSTA')){
                    regionWo = 'VALLE D'+'\''+'AOSTA';
                }
                if(regionWo != null && mapRegionListOfIdUser.get(regionWo) != null){
                    setOfUserId.addAll(mapRegionListOfIdUser.get(regionWo));
                }
            }
        }
        return new List<Id> (setOfUserId);
    }

}
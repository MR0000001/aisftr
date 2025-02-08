/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date Creation 16/04/2019
 * @date Modification dd/mm/yyyy
 * @description XC_TR_Account_U_PartnerDeactivation - For Partner Activation/Deactivation
 */

public without sharing class XC_TR_Account_U_PartnerDeactivation {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Account_U_PartnerDeactivation');

    /** @description Manage DML Wrapper */
    public class ManageDMLWrapper {
        public List<User> listUserToUpdate = new List<User>();
        public List<ServiceResource> listServiceResourceToUpdate = new List<ServiceResource>();
        public List<User> listUserToUpdateLater = new List<User>();
        public List<ServiceResource> listServiceResourceToUpdateLater = new List<ServiceResource>();
        public Boolean nextQueue = true;
    }

    /** @description Manage DML (Queuable) - Queue1 */
    public class ManageDMLFirstQueue implements Queueable {
        
        List<User> listUserToUpdate = new List<User>();
        List<ServiceResource> listServiceResourceToUpdate = new List<ServiceResource>();
        List<User> listUserToUpdateLater = new List<User>();
        List<ServiceResource> listServiceResourceToUpdateLater = new List<ServiceResource>();
        
        /**
         * @description Instantiates a new Manage DML queuable
         * @param wrapper - ManageDMLWrapper
         */
        public ManageDMLFirstQueue(ManageDMLWrapper wrapper) {
            this.listUserToUpdate = wrapper.listUserToUpdate;
            this.listServiceResourceToUpdate = wrapper.listServiceResourceToUpdate;
            this.listUserToUpdateLater = wrapper.listUserToUpdateLater;
            this.listServiceResourceToUpdateLater = wrapper.listServiceResourceToUpdateLater;
        }
        
        /**
         * @description Execute Queuable
         * @param context - QueueableContext
         */
        public void execute(QueueableContext context) {
            List<XC_UTIL_Sobject.WrapperResult> wrapperResultActive = XC_UTIL_DML.updateRecords(listUserToUpdate, true);
            if(XC_UTIL_Sobject.checkDMLresults(wrapperResultActive) && !Test.isRunningTest()) {
                ManageDMLWrapper manageDMLWrapper = new ManageDMLWrapper();
                manageDMLWrapper.listServiceResourceToUpdate = this.listServiceResourceToUpdate;
                manageDMLWrapper.listUserToUpdateLater = this.listUserToUpdateLater;
                manageDMLWrapper.listServiceResourceToUpdateLater = this.listServiceResourceToUpdateLater;
                manageDMLWrapper.nextQueue = true;
                System.enqueueJob(new ManageDMLSecondQueue(manageDMLWrapper));
            }
        }
    }

    /** @description Manage DML (Queuable) - Queue2 */
    public class ManageDMLSecondQueue implements Queueable {
        
        List<ServiceResource> listServiceResourceToUpdateLater = new List<ServiceResource>();
        List<ServiceResource> listServiceResourceToUpdate = new List<ServiceResource>();
        List<User> listUserToUpdateLater = new List<User>();
        Boolean nextQueue = false;
        
        /**
         * @description Instantiates a new Manage DML queuable
         * @param manageDMLWrapper - ManageDMLWrapper
         */
        public ManageDMLSecondQueue(ManageDMLWrapper manageDMLWrapper) {
            this.listServiceResourceToUpdateLater = manageDMLWrapper.listServiceResourceToUpdateLater;
            this.listServiceResourceToUpdate = manageDMLWrapper.listServiceResourceToUpdate;
            this.listUserToUpdateLater = manageDMLWrapper.listUserToUpdateLater;
            this.nextQueue = manageDMLWrapper.nextQueue;
        }
        
        /**
         * @description Execute Queuable
         * @param context - QueueableContext
         */
        public void execute(QueueableContext context) {
            if(this.nextQueue) {
                XC_UTIL_DML.updateRecords(this.listServiceResourceToUpdateLater, true);
                List<ServiceResource> listServiceResourceActiveToUpdate = new List<ServiceResource>();
                for(ServiceResource sr : this.listServiceResourceToUpdate) {
                    if(sr.RelatedRecord.IsActive) {
                        listServiceResourceActiveToUpdate.add(sr);
                    }
                }
                List<XC_UTIL_Sobject.WrapperResult> wrapperResultDeactive = XC_UTIL_DML.updateRecords(listServiceResourceActiveToUpdate, true);
                if(XC_UTIL_Sobject.checkDMLresults(wrapperResultDeactive)) {
                    ManageDMLWrapper manageDMLWrapper = new ManageDMLWrapper();
                    manageDMLWrapper.listServiceResourceToUpdate = listServiceResourceActiveToUpdate;
                    manageDMLWrapper.listUserToUpdateLater = this.listUserToUpdateLater;
                    manageDMLWrapper.listServiceResourceToUpdateLater = this.listServiceResourceToUpdateLater;
                    manageDMLWrapper.nextQueue = false;
                    enqueueJobSecondQueue(manageDMLWrapper);
                }
            } else {
                XC_UTIL_DML.updateRecords(this.listUserToUpdateLater, true);
            }
        }

        private void enqueueJobSecondQueue(ManageDMLWrapper manageDMLWrapper){
            if(!Test.isRunningTest()){
                System.enqueueJob(new ManageDMLSecondQueue(manageDMLWrapper));
            }
        }
    }


    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 16/04/2019
    * @description Check status ServiceResource/User
    * @param mapOld - Map<Id, Account>
    * @param mapNew - Map<Id, Account>
    */
    public static void checkPartnerStatus(Map<Id, Account> mapOld, Map<Id, Account> mapNew) {
        List<Account> listAccount = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_Status__c'}, mapNew, mapOld);        
        List<Id> listAccountId = XC_UTIL_Sobject.getIds(listAccount);

        List<ServiceResource> listServiceResource = new List<ServiceResource>([
            SELECT Id, RelatedRecordId, ResourceType, XC_AccountName__c, RelatedRecord.IsActive, XC_Account__r.XC_Status__c, XC_AutomaticDeactivation__c, RelatedRecord.XC_AutomaticDeactivation__c 
            FROM ServiceResource
            WHERE XC_Account__c IN :listAccountId
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listServiceResource ---> ' + listServiceResource);

        if(!listServiceResource.isEmpty()) {  
            ManageDMLWrapper wrapperManageDML = populateManageDMLWrapper(listServiceResource);
            System.enqueueJob(new ManageDMLFirstQueue(wrapperManageDML));
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 17/04/2019
    * @description Populate Manage DML Wrapper
    * @param listServiceResource - List<ServiceResource> 
    * @return wrapperManageDML - ManageDMLWrapper
    */
    private static ManageDMLWrapper populateManageDMLWrapper(List<ServiceResource> listServiceResource) {
        ManageDMLWrapper wrapperManageDML = new ManageDMLWrapper();

        for(ServiceResource sr : listServiceResource) {
            User user = new User();
            if(sr.XC_Account__r.XC_Status__c == Label.XC_CL_Account_StatusActive) {
                if(sr.XC_AutomaticDeactivation__c) {
                    // Active User:
                    user.Id = sr.RelatedRecordId;
                    user.IsActive = true;
                    user.XC_AutomaticDeactivation__c = false;
                    wrapperManageDML.listUserToUpdate.add(user);
                    // Active ServiceResource:
                    sr.IsActive = true;
                    sr.XC_AutomaticDeactivation__c = false;
                    wrapperManageDML.listServiceResourceToUpdateLater.add(sr);
                }
            } else if(sr.XC_Account__r.XC_Status__c == Label.XC_CL_Account_StatusInactive) {
                // De-active ServiceResource:
                sr.XC_AutomaticDeactivation__c = true;
                sr.IsActive = false;
                wrapperManageDML.listServiceResourceToUpdate.add(sr);
                // De-active User:
                user.Id = sr.RelatedRecordId;
                user.IsActive = false;
                user.XC_AutomaticDeactivation__c = true;
                wrapperManageDML.listUserToUpdateLater.add(user);
            }
        }

        return wrapperManageDML;
    }
}
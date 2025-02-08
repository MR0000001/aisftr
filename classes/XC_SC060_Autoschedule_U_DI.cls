public with sharing class XC_SC060_Autoschedule_U_DI {

    private List<Account> accountForSaturation;
    private WorkOrder wo;
    private Map<Id,Id> directElegibilityList;
    private Account accountPartner;
    private Map<Id, ServiceResource> srManagerMap;
    private XC_CM_Scheduling_Default_Value__mdt metadata;
    private OperatingHours operatingHours;
    //private Map<Id,ServiceAppointment> serviceAppointmentMap; works with getServiceAppointmentsFromWorkOrder_OLD
    private ServiceAppointment serviceAppointment;
    private FSL__Scheduling_Policy__c policy;

    public XC_SC060_Autoschedule_U_DI(WorkOrder wo,Account accountPartner,List<Account> accountForSaturation,Map<Id,Id> directElegibilityList, Map<Id, ServiceResource> srManagerMap , XC_CM_Scheduling_Default_Value__mdt metadata, OperatingHours operatingHours, ServiceAppointment serviceAppointment,  FSL__Scheduling_Policy__c policy) {
        this.accountForSaturation = accountForSaturation;
        this.wo = wo;
        this.directElegibilityList = directElegibilityList;
        this.accountPartner = accountPartner;
        this.srManagerMap = srManagerMap;
        this.metadata = metadata;
        this.operatingHours = operatingHours;
        this.serviceAppointment = serviceAppointment;
        this.policy = policy;
    }
    
     private final static Boolean DEBUGACTIVE = true;

    public void scheduleAppointment(){
        XC_UTIL_Schedule.BookingResult result = new XC_UTIL_Schedule.BookingResult();
        Account account = null;
        Boolean scheduled = false;

        if(this.directElegibilityList.get(wo.Id) != null){
            account = new Account(Id= this.directElegibilityList.get(wo.Id));
        }
		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@# ' + account);
        /*if(account == null && metadata.XC_Allow_Assignment_By_Saturation__c){ works with getServiceAppointmentsFromWorkOrder_OLD
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ saturation XC_SC060_Autoschedule');
            System.debug('@#@# yes saturation');
            for(Account acc : accountForSaturation){
                ServiceAppointment sa = serviceAppointmentMap.get(acc.Id);
                //try to schedule foreach account
                XC_SC060_Autoschedule_U.setServiceResourcePreference(wo.Id, srManagerMap.get(acc.id));
                System.debug('@#@# '+ sa +' ' + policy +  ' ' +   operatingHours);
                scheduled = XC_SC060_Autoschedule_U.scheduleServiceAppointment(sa, policy, operatingHours);
                if(scheduled){
                    break;
                }else{
                    //XC_SC060_Autoschedule_U.clearResourcePreference(wo.Id);
                }
                // if one schedulation work fine --> break;
            }
        }else {*/
        if(account == null && metadata.XC_Allow_Assignment_By_Saturation__c){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ saturation XC_SC060_Autoschedule');
            System.debug('@#@# yes saturation');
            
                ServiceAppointment sa = serviceAppointment;
                System.debug('@#@# '+ sa +' ' + policy +  ' ' +   operatingHours);
                scheduled = XC_SC060_Autoschedule_U.scheduleServiceAppointment(sa, policy, operatingHours);
                 
        }else {
            
            System.debug('@#@# no saturation');
            //try to schedule with account
            if(account != null) {
                System.debug('@#@#  diretto');
                if(srManagerMap.get(account.id) !=null){
                    System.debug('SC060 ha manager');
                    XC_SC060_Autoschedule_U.setServiceResourcePreference(wo.Id, srManagerMap.get(account.id));
                	ServiceAppointment sa = serviceAppointment;
                	scheduled = XC_SC060_Autoschedule_U.scheduleServiceAppointment(sa, policy, operatingHours);
                    //XC_SC060_Autoschedule_U.clearResourcePreference(wo.Id);
                }
            }
        }
      

        if(!scheduled){
            WorkOrder updateWo = XC_SC060_Autoschedule_U.setWordOrderAsManual(wo);
        }
    }
}
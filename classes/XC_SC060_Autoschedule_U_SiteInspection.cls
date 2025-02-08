public with sharing class XC_SC060_Autoschedule_U_SiteInspection {

    private List<Account> accountForSaturation;
    private WorkOrder wo;
    private Map<Id,Id> directElegibilityList;
    private Account accountPartner;
    Map<Id, ServiceResource> srManagerMap;
    private XC_CM_Scheduling_Default_Value__mdt metadata;
    private OperatingHours operatingHours;
    //private Map<Id,ServiceAppointment> serviceAppointmentMap; works with getServiceAppointmentsFromWorkOrder_OLD
    private ServiceAppointment serviceAppointment;
    FSL__Scheduling_Policy__c policy;

    public XC_SC060_Autoschedule_U_SiteInspection(WorkOrder wo,Account accountPartner,List<Account> accountForSaturation,Map<Id,Id> directElegibilityList,  Map<Id, ServiceResource> srManagerMap, XC_CM_Scheduling_Default_Value__mdt metadata, OperatingHours operatingHours, ServiceAppointment serviceAppointment, FSL__Scheduling_Policy__c policy) {
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

    public void scheduleAppointment(){
        XC_UTIL_Schedule.BookingResult result = new XC_UTIL_Schedule.BookingResult();
        Account account = null;
        Boolean scheduled = false;

        if(this.directElegibilityList.get(wo.Id) != null){
            account = new Account(Id= this.directElegibilityList.get(wo.Id));
        }

        /*if(account == null && metadata.XC_Allow_Assignment_By_Saturation__c){

            for(Account acc : accountForSaturation){
                ServiceAppointment sa = serviceAppointment;
                //try to schedule foreach account
                XC_SC060_Autoschedule_U.setServiceResourcePreference(wo.Id, srManagerMap.get(acc.id));
                scheduled = XC_SC060_Autoschedule_U.scheduleServiceAppointment(sa, policy, operatingHours);
                if(scheduled){
                    break;
                }else{
                    XC_SC060_Autoschedule_U.clearResourcePreference(wo.Id);
                }
                // if one schedulation work fine --> break;
            }
        }else {*/
        if(account == null && metadata.XC_Allow_Assignment_By_Saturation__c){
            System.debug('@#@# yes saturation');
            
                ServiceAppointment sa = serviceAppointment;
                System.debug('@#@# '+ sa +' ' + policy +  ' ' +   operatingHours);
                scheduled = XC_SC060_Autoschedule_U.scheduleServiceAppointment(sa, policy, operatingHours);
                 
        }else {
            //try to schedule with account
            
            System.debug('@#@# no saturation');
            if(account != null) {
                System.debug('@#@#  diretto');
                if(srManagerMap.get(account.id) !=null){
                    System.debug('SC060 Ha manager');
                
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
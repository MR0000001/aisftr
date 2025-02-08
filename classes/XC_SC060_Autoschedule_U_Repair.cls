public with sharing class XC_SC060_Autoschedule_U_Repair {

    private WorkOrder wo;
    private Map<Id,Id> directElegibilityList;
    private Account accountPartner;
    private  Map<Id, ServiceResource> srManagerMap;
    private XC_CM_Scheduling_Default_Value__mdt metadata;
    private OperatingHours operatingHours;
    //private Map<Id,ServiceAppointment> serviceAppointmentMap; works with getServiceAppointmentsFromWorkOrder_OLD
    private ServiceAppointment serviceAppointment;
    FSL__Scheduling_Policy__c policy;

    public XC_SC060_Autoschedule_U_Repair(WorkOrder wo,Account accountPartner,Map<Id,Id> directElegibilityList,  Map<Id, ServiceResource> srManagerMap, XC_CM_Scheduling_Default_Value__mdt metadata, OperatingHours operatingHours,ServiceAppointment serviceAppointment,  FSL__Scheduling_Policy__c policy) {
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
		System.debug('@#@# '+ serviceAppointment +' ' + policy +  ' ' +   operatingHours);
        //try to schedule with account
            
        if(account != null) {
            System.debug('@#@#  diretto');
            if(srManagerMap.get(account.id) !=null){
                System.debug('SC060 Ha manager');
                
                XC_SC060_Autoschedule_U.setServiceResourcePreference(wo.Id, srManagerMap.get(account.id));
                ServiceAppointment sa = serviceAppointment;
                System.debug('@#@# '+ sa +' ' + policy +  ' ' +   operatingHours);
                scheduled = XC_SC060_Autoschedule_U.scheduleServiceAppointment(sa, policy, operatingHours);
                //XC_SC060_Autoschedule_U.clearResourcePreference(wo.Id);
            }
        }

        if (!scheduled) {
            WorkOrder updateWo = XC_SC060_Autoschedule_U.setWordOrderAsManual(wo);
        }
    }
}
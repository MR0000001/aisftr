/**
     * @description  XC_TR_Configuration_U_CountConfUtil - Util class for XC_TR_Configuration_U_CountConf
     */
public class XC_TR_Configuration_U_CountConfUtil{

    /**
     * @description  Avoid recursion.
     * @return the boolean
     */ 
    public static Boolean avoidRecursion(){

        if(!XC_TR_Configuration_U_CountConf.wasCalled){
            XC_TR_Configuration_U_CountConf.wasCalled = true;
            return false;
        }else{ 
            return XC_TR_Configuration_U_CountConf.wasCalled;
        }
    }


    private static Boolean checkCondition(XC_TR_Configuration_U_CountConf.checkWrapper wrapper) {
        Boolean check = false;
        Opportunity opp = wrapper.opp;
        String confRecordType = wrapper.confRecordType;
        String eventCall = wrapper.eventCall;
        Map<Id,NE__Order__c> oldConfigurations = wrapper.oldConfigurations;
        NE__Order__c configuration = wrapper.configuration;
        
        if(opp != null      
            && confRecordType == Label.XC_CL_Configuration_RtQuote
            && eventCall == XC_TR_Configuration_U_CountConf.FROM_UPDATE 
            && oldConfigurations != null
            && !oldConfigurations.isEmpty() 
            && oldConfigurations.containsKey(configuration.Id) ){
                check = true;
        }
        return check;
    } 

    /**
     * @description  util Method
     * @param  wrapper
     */ 
    public static void utilMethod(XC_TR_Configuration_U_CountConf.UtilWrapper wrapper){ 
        Opportunity opp = wrapper.opp;
        NE__Order__c configuration = wrapper.configuration;
        String eventCall = wrapper.eventCall;
        Map<Id,NE__Order__c> oldConfigurations = wrapper.oldConfigurations;
        Set<NE__Order__c> configurationsToUpdate = wrapper.configurationsToUpdate;
        String confRecordType = configuration.RecordType.DeveloperName;
        XC_TR_Configuration_U_CountConf.checkWrapper checkWr = new XC_TR_Configuration_U_CountConf.checkWrapper();
        checkWr.opp = opp;
        checkWr.confRecordType = confRecordType;
        checkWr.eventCall = eventCall;
        checkWr.oldConfigurations = oldConfigurations;
        checkWr.configuration = configuration;
        System.debug('newConf = '+checkWr.configuration);
        System.debug('oldConf = '+ checkWr.oldConfigurations );
        if(checkCondition(checkWr)){ 
            //CHECK IF STATUS NEW->ACCEPTED 
            if (configuration.XC_Status__c == Label.XC_CL_Configuration_QuoteAccepted 
                        && oldConfigurations.get(configuration.Id).XC_Status__c != Label.XC_CL_Configuration_QuoteAccepted){

                configurationsToUpdate.addAll(XC_TR_Configuration_U_CountConf.setQuoteConfToRejected(opp,configuration)); // GS 27/12/2018 - the opportunity no longer need to be closedWon if the 'quote conf' is closed
                XC_TR_Configuration_U_CountConf.wasCalled = avoidRecursion();
            }
        }
    } 

     /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @param mapNew the map of new configurations versions
     * @return the last rejected quote
     * @description search for the last rejected quote
     */
    public static NE__Order__c getLastQuoteRejected(Map<Id, NE__Order__c> mapNew) {
        DateTime closeDateTime = DateTime.newInstance(1970, 1, 1, 0, 0, 0);
        NE__Order__c lastQuote;

        for(NE__Order__c quote : mapNew.values()) {
            if(quote.LastModifiedDate > closeDateTime) {
                lastQuote = quote;
            }
        }
        return lastQuote;
    }
    /**
    * @description update Status of WorkOrder and his related Service Appointment
    * @author Valeria Martino - valeria.martino@nttdata.com
    * @param listOrder - List<NE__Order__c>
    **/
    public static void updateStatusWoWithSa(List<NE__Order__c> listOrder){
        List<WorkOrder> listWorkOrder = new List<WorkOrder>();
        List<String> listOrderIds =XC_UTIL_Sobject.getIds(listOrder);
        listWorkOrder = XC_TR_Configuration_U_CountConf_D.getWorkOrderWithSa(listOrderIds);  
        List<Workorder> listWorkOrderToUpdate = new List<Workorder>();
        List<ServiceAppointment> listServiceAppointment = new List<ServiceAppointment>();
        for(Workorder wo: listWorkOrder) {
            wo.Status = Label.XC_CL_Cancelled;
            listWorkOrderToUpdate.add(wo);
            for(ServiceAppointment sa : wo.ServiceAppointments) {
                sa.Status = Label.XC_CL_Cancelled;
                sa.XC_StatusReason__c = '';
                listServiceAppointment.add(sa);
            }
        }
        System.debug('WorkOrder Status to update' + listWorkOrderToUpdate);
        XC_UTIL_Sobject.updateListRecords(listWorkOrderToUpdate); 
        
        System.debug('Serivce Appointment to update' + listServiceAppointment);
        XC_UTIL_Sobject.updateListRecords(listServiceAppointment); 
    }

}
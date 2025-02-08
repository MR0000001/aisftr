/**
 * @description The Class XC_LCC045_WorkOrderEmailInTravel.
 */
public without sharing class XC_LCC045_WorkOrderEmailInTravel {
    
        /**
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date 12/02/2019
* @description update SA field with operator's delay.
* @return ServiceAppointment
* @param String
*/
    @AuraEnabled
    public static XC_UTIL_ResultWrapper updateServiceAndSend(String interactionValues){
         Map<String,Object> values = (Map<String,Object>) JSON.deserializeUntyped(interactionValues);
         String emailType = '';
         Integer delay;
         
	     if(values.get('customerType') != null){
            emailType = (String)values.get('customerType');
         }
         if(values.get('delay') != null){
            delay = Integer.valueOf((String)values.get('delay'));
         }
         if(emailType!=''){
             ServiceAppointment sa = XC_UTIL_ServiceAppointment.getActiveSAFromWo((String)values.get('workorderId'));
             if(sa!=null && emailType=='WorkOrder_StartTravel'){
                 sa.XC_TravelMinutes__c = delay;
             }else if(sa!=null && emailType=='WorkOrder_DelayTravel')  {
                 sa.XC_DelayMinutes__c = delay;
             } 
             update sa;
             values.put('serviceAppointmentId' , sa.id);
             interactionValues = JSON.serialize(values);
         }
        

        return newEmailForCustomer(interactionValues);
    }
    
/**
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date 12/02/2019
* @description return wrapper with info on customer inter insert result.
* @return XC_UTIL_ResultWrapper
* @param String
*/
    @AuraEnabled
    public static XC_UTIL_ResultWrapper newEmailForCustomer(String interactionValues){
        return XC_LCC039_CustomerInteraction.newEmailForCustomer(interactionValues);
    }
    
    /**
     * @description Check possibility to send.
     *
     * @param recordId the record id
     * @return the x C UTI L result wrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkPossibilityToSend(String recordId){
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;
        Boolean canSend = false;
        System.debug('entrato in checkPossibilityToSend');
        if(!Schema.SObjectType.WorkOrder.isAccessible()) {
            rw.resultMessage = Label.XC_CL_InsufficientPrivileges;
            rw.success = false;
            return rw;
        }
        Map<Id,WorkOrder> woMap = new Map<Id,WorkOrder>([SELECT Id,XC_WorkTypeCategory__c,		
                              (SELECT Id, SchedStartTime FROM ServiceAppointments where Status='Scheduled' OR Status='Dispatched') 
                                 FROM WorkOrder WHERE Id =:recordId ]);
        List<WorkOrder> wo = woMap.values();



        if(wo.isEmpty() || wo[0].ServiceAppointments.isEmpty()){
            System.debug('ServiceAppointments NOT exist');
            rw.success = false;
            rw.resultMessage = Label.XC_CL_CustomerInteraction_NotInTimeSA;
            return rw;
        }else{
            //System.debug('ServiceAppointments exist, XC_WorkTypeName__c='+wo[0].XC_WorkTypeName__c);

            if(wo[0].XC_WorkTypeCategory__c != Label.XC_CL_WorkType_DeliveryInstallation &&
               wo[0].XC_WorkTypeCategory__c != Label.XC_CL_WorkType_Installation &&
               wo[0].XC_WorkTypeCategory__c != Label.XC_CL_CommercialVisit &&
               wo[0].XC_WorkTypeCategory__c != Label.XC_CL_WorkType_SalesSiteInspection &&
               wo[0].XC_WorkTypeCategory__c != Label.XC_CL_WorkType_SiteInspection){
                rw.resultMessage = Label.XC_CL_CustomerInteraction_WorkTypeNotAccepted;
                rw.success = false;
                return rw;
            }

            List<ServiceAppointment> saList = new List<ServiceAppointment>();
            saList.add(wo[0].ServiceAppointments[0]);
            canSend = XC_UTIL_ServiceAppointment.checkRangeTimeOnServiceAppointment(saList);
            System.debug('canSend = '+canSend);
            if(!canSend){
                 rw.success = false;
                 rw.resultMessage = Label.XC_CL_CustomerInteraction_NotInTimeSA;

            }

            return rw;
        }
    }

}
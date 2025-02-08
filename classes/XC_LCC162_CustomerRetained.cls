/**
* @author Massimiliano Avallone - massimiliano.avallone@nttdata.com
* @date Creation: 10/10/2019
* @date Modification:
* @description XC_LCC162_CustomerRetained - Controller class of the component XC_LCC162_CustomerRetained.
*/
public without sharing class XC_LCC162_CustomerRetained{
     
   /** @description ResultWrapper */
    public class ResultWrapper { 
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public String  resultMessage = '';
    } 
    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC162_CustomerRetained');
    /**
    * @author Massimiliano Avallone - massimiliano.avallone@nttdata.com
    * @param workOrderId
    * @description assign status and statusReason at the Work Orders
    * @return Boolean
    */
    @AuraEnabled        
    public static ResultWrapper updateFLS(String workOrderId){
        ResultWrapper resWrapper = new ResultWrapper();
        
        List<WorkOrder> woList = new List<WorkOrder>([
            SELECT Id, XC_WorkTypeCategory__c, (SELECT Id from ServiceAppointments)
            FROM WorkOrder 
            WHERE Id = :workOrderId
        ]);
        
        WorkOrder wo = woList[0];
            List<ServiceAppointment> listServiceAppointment = new List<ServiceAppointment>();  
            if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance){  
                for (serviceAppointment sa : wo.ServiceAppointments){
                    sa.XC_StatusReason__c = Label.XC_CL_StatusReason_CustomerRetained;
                    listServiceAppointment.add(sa);
                } 
                if(!listServiceAppointment.isEmpty()){
                  resWrapper = updateSA(listServiceAppointment, resWrapper);
                }else{
                    resWrapper.success = false;
                    resWrapper.resultMessage = Label.XC_CL_ServiceAppointmentNotExist;
                    }
            }else{
                  resWrapper.success = false;
                  resWrapper.resultMessage = Label.XC_CL_WorkOrder_WorktypeError;
            }
        return resWrapper; 
	}

     /**
    * @author Massimiliano Avallone - massimiliano.avallone@nttdata.com
    * @param listServiceAppointment
    * @param resWrapper
    * @description update service appointment
    * @return resWrapper
    */
    public static ResultWrapper updateSA (List<ServiceAppointment> listServiceAppointment, ResultWrapper resWrapper)
    {
        List<XC_UTIL_Sobject.wrapperResult> wrapperList  = XC_UTIL_Sobject.updateListRecords(listServiceAppointment);
        if (XC_UTIL_Sobject.checkDMLResults(wrapperList)){
            resWrapper.success = true;
        }else{
            resWrapper.success = wrapperList[0].success;            
            resWrapper.resultMessage = wrapperList[0].errorMessage;
        }
        return resWrapper;
    } 
    
}
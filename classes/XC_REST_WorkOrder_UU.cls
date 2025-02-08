/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 24/04/2019
* @description REST Utility Class for WorkOrder Interface   
*/   
public with sharing class XC_REST_WorkOrder_UU {

    /**
     * @description handle the read operation
     *
     * @param params the request 
     * @return a list of work orders
     */
    public static List<XC_UTIL_WorkOrder.WorkOrderWrapper> readWorkOrder(Map<String, String> params, String clientSystem){ 
        List<WorkOrder> res = new List<WorkOrder>();

        if (!string.isBlank(params.get('WorkOrderNumber'))) {                                                                   // Search by WorkOrderNumber
            res = XC_REST_WorkOrder_U_D.getWorkOrderByNumber( params.get('WorkOrderNumber') );

        } else if (!string.isBlank(params.get('WorkOrderID'))) {                                                                // Search by WorkOrderID  
            res = XC_REST_WorkOrder_U_D.getWorkOrderById( params.get('WorkOrderID') );

        } else if (!string.isBlank(params.get('AssetID'))) {                                                                    // Search by assetID  
            res = XC_REST_WorkOrder_U_D.getWorkOrderByAsset( params.get('AssetID') );

        } else if (!string.isBlank(params.get('ServiceResourceID'))) {                                                          // Search by ServiceResource
            res = XC_REST_WorkOrder_U_D.getWorkOrderByResourceAndDates( params.get('ServiceResourceID'),
                                                                        Date.valueOf(params.get('StartDate')),
                                                                        Date.valueOf(params.get('EndDate')) );

        } else {
            res = readWorkOrderBIS(params);

            if(res.isEmpty()){
                res = readWorkOrderTRIS(params);
            }

        }

        List<XC_UTIL_WorkOrder.WorkOrderWrapper> wolist = new List<XC_UTIL_WorkOrder.WorkOrderWrapper>();

        //Document Compliance 
        List<Id> workOrderIdList = new List<Id>();
        for (workorder wo : res ) {
            workOrderIdList.add(wo.Id);
        }
        Map<Id,Map<String,Integer>> documentMap = XC_TR_WorkOrder_U_FinalStatus.getWOComplianceDocuments(workOrderIdList);

        for (workorder wo : res ) {
            wolist.add(XC_REST_WorkOrder_W.createWorkOrderWrapper(wo, wo.WorkOrderLineItems, wo.ServiceAppointments, documentMap, clientSystem));
        }

        return wolist; 
    }

    private static List<WorkOrder> readWorkOrderBIS(Map<String, String> params){ 
        List<WorkOrder> res = new List<WorkOrder>();

        if (!string.isBlank(params.get('AccountID')) && !string.isBlank(params.get('Email'))) {                          // Search by Account + lead email
            if (checkDates(params)) {                                                           
                res = XC_REST_WorkOrder_U_D.getWoByLeadOrAccountWithDates(params);
            
            } else {
                res = XC_REST_WorkOrder_U_D.getWoByLeadOrAccount(params);

            }

        } else if (!string.isBlank(params.get('AccountID'))) {                                                                  // Search by Account
            if (checkDates(params)) {                                                           
                res = XC_REST_WorkOrder_U_D.getWorkOrderByAccountAndDates(  params.get('AccountID'),
                                                                            Date.valueOf(params.get('StartDate')),
                                                                            Date.valueOf(params.get('EndDate')) );
            } else {
                res = XC_REST_WorkOrder_U_D.getWorkOrderByAccount(params.get('AccountID'));

            }

        } else if (!string.isBlank(params.get('Email'))) {                                                                       // Search by lead email

            if (checkDates(params)) {
                res = XC_REST_WorkOrder_U_D.getWorkOrderByLeadEmailAndDates(    params.get('Email'),
                                                                                Date.valueOf(params.get('StartDate')),
                                                                                Date.valueOf(params.get('EndDate')) );
            } else {
                res = XC_REST_WorkOrder_U_D.getWorkOrderByLeadEmail(params.get('Email'));

            }           
        } 

        return res;
    }

    private static List<WorkOrder> readWorkOrderTRIS(Map<String, String> params){ 
        List<WorkOrder> res = new List<WorkOrder>();
		String type = params.get('WorkType');
        String ordId = params.get('OrderId');
        
        if (!string.isBlank(ordId)) {                                                                      // Search by Order
            if (!string.isBlank(type)) {         
                res = XC_REST_WorkOrder_U_D.getWoByOrderAndWorkType(type.replaceAll('and','&').split(','), ordId);
                
            } else {
                res = XC_REST_WorkOrder_U_D.getWoByOrder(params);
            }                                                                    
        }

        return res;
    }

    /**
     * @description handle the update operation
     *
     * @param wrReq the request 
     * @return the work order to update
     */
    public static WorkOrder getWorkOrderForUpdate(XC_REST_WorkOrder_W.Wrapper wrReq){
        WorkOrder woToMod;

        List<String> wliNumb = XC_REST_WorkOrder_UU.getWoliNumbs(wrReq.WorkOrder.workorderlineitem);
        List<String> appNumb = XC_REST_WorkOrder_UU.getSaNumbs(wrReq.WorkOrder.serviceappointment);

        if (string.isNotBlank(wrReq.WorkOrder.WorkOrderNumber)) {
            woToMod = XC_REST_WorkOrder_U_D.getWorkOrderByNumber(wrReq.WorkOrder.WorkOrderNumber)[0];
        } else {
            woToMod = XC_REST_WorkOrder_U_D.getWorkOrderById(wrReq.WorkOrder.WorkOrderID)[0]; 
        }  

        return woToMod;
    }

    private static List<String> getSaNumbs(List<XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper> apps){
        List<String> res = new List<String>();

        if (apps!=null){
            for ( XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper s : apps) {
                res.add(s.AppointmentNumber);
            }
        }

        return res;
    }

    private static List<String> getWoliNumbs(List<XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper> wolis){
        List<String> res = new List<String>();

        if (wolis!=null){
            for ( XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper w : wolis) {
                res.add(w.WorkOrderLineItemNumber);
            }
        }

        return res;
    }

    private static boolean checkDates(Map<String, String> params){
        return (!string.isBlank(params.get('StartDate'))&&!string.isBlank(params.get('EndDate')));
    }

}
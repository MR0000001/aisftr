/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
public with sharing class XC_LCC186_CreateProjectCheckProvIsOk {




    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkProvvisioning(String recordId){
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        String orderId = recordId;
        String orderIdOld = recordId;
        String orderIdNew = recordId;
        String orderIdbefore = recordId;
        System.debug('recordId-->'+recordId);
        List<NE__OrderItem__c> quoeryOnOrderItems = new List<NE__OrderItem__c>();
        quoeryOnOrderItems = quoeryOnOrderItems(orderID);



        System.debug('listOrderItems-->'+quoeryOnOrderItems);

        if(checkExsistngProjectOnOrderItem(quoeryOnOrderItems)){
                //return Label.XC_CL_PPM_PROJECT_EXIST;//'The project already exists';
            populateWrapperFailedStopExecution(rw, Label.XC_CL_PPM_PROJECT_EXIST);
            return rw;

        }
        if(checkExsistngProjectOnOrder(recordId)){
           //return Label.XC_CL_PPM_PROJECT_EXIST; //'The project already exists';
            populateWrapperFailedStopExecution(rw, Label.XC_CL_PPM_PROJECT_EXIST);
            return rw;
       }

        if(checkTemplateIsFilled(quoeryOnOrderItems)){
            //return Label.XC_CL_PPM_INSERT_TEMPLATE;//'Please insert project template';
            populateWrapperFailedStopExecution(rw, Label.XC_CL_PPM_INSERT_TEMPLATE);
            return rw;
        }
      /*  if(checkProjectIsLinkedToOpportunity(quoeryOnOrderItems)){
            populateWrapperSuccess(rw,Label.XC_CL_OrderUpdated,'SUCCESS');
            return rw;

        }*/


        if(checkMilestoneTotal(orderId)){
            populateWrapperFailedStopExecution(rw, Label.XC_CL_MilestoneTotalRateErr);
            return rw;
            //return Label.XC_CL_MilestoneTotalRateErr;//'Milestone total rates must be 100%';
        }
        populateWrapperSuccess(rw,XC_LCC186_CreateProjectPPM.createProject(quoeryOnOrderItems),'SUCCESS');
        return rw;

    }




    private static List<NE__OrderItem__c> quoeryOnOrderItems(String orderID){
        System.debug('orderId-->'+orderId);
        List<NE__OrderItem__c> listOrderItems = [select (select id from Projects__r), (select id, XC_Rate__c, name, XC_StartDate__c,XC_EndDate__c,XC_OrderItem__c,XC_IsBilled__c from XC_Milestones__r), XC_BillingModel__c, XC_TotalPriceOneShot__c,XC_RecurringDuration__c,NE__RecurringChargeFrequency__c,XC_TotalPriceRecurring__c, NE__OrderId__r.XC_Segment__c, NE__OrderId__r.XC_Compliance_Approval__c, NE__OrderId__c,XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_Country__c, id,NE__OrderId__r.NE__AccountId__r.name, XC_Country__c, NE__OrderId__r.name, NE__OrderId__r.NE__AccountId__c, Name,NE__Account__c, XC_Project_Template__c, NE__Parent_Order_Item__c, RecordType.DeveloperName,  NE__OrderId__r.id, NE__OrderId__r.XC_Project_Template__c, XC_LegalEntityFormula__c, NE__OneTimeFeeOv__c, NE__OrderId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c,  NE__Account__r.name, NE__OrderId__r.NE__One_Time_Fee_Total__c, XC_PaymentMethod__c, NE__OrderId__r.XC_OptyProjectId__c    from NE__OrderItem__c where NE__OrderId__c =:orderID];
        return listOrderItems;
    }

    private static Boolean checkExsistngProjectOnOrderItem(List<NE__OrderItem__c> quoeryOnOrderItems){
        Boolean check = False;
        for(NE__OrderItem__c ne : quoeryOnOrderItems){
            for(project_cloud__Project__c i : ne.Projects__r)
           // System.debug('Projects__r-->'+ne.Projects__r.id);
            if(i != Null ){
                check = True;
            }
        }
        return check;
    }

    private static Boolean checkExsistngProjectOnOrder(String recordId){
        Boolean check = False;
        List<project_cloud__Project__c> listProject = [select id, XC_Configuration__c  from project_cloud__Project__c where XC_Configuration__c= :recordId];
        if(!listProject.isEmpty()){
            return True;
        }
        return check;
    }


    private static Boolean checkTemplateIsFilled(List<NE__OrderItem__c> quoeryOnOrderItems){
        Boolean check = True;
        for (NE__OrderItem__c ne : quoeryOnOrderItems){
            if(ne.XC_Project_Template__c != Null || ne.NE__OrderId__r.XC_Project_Template__c != Null){
                check = False;
            }
        }
        return check;

    }












    private static Boolean checkMilestoneTotal(String recordId){
        Boolean check = False;

        AggregateResult[] groupedResults
                = [select sum(XC_Rate__c) tot, XC_OrderItem__c
                    from XC_milestone__c
                    where XC_OrderItem__r.NE__OrderId__c = :recordId
                    and XC_OrderItem__r.XC_BillingModel__c = 'Milestone'
                    group by XC_OrderItem__c];
        if(groupedResults.isEmpty()){
            return False;
        }

        for(AggregateResult res : groupedResults) {
            Double sumAmount = Double.valueOf(res.get('tot'));
            if(sumAmount!=100.0){
                return True;
            }
        }

        return check;
    }


/*
    public static Boolean checkProjectIsLinkedToOpportunity(List<NE__OrderItem__c> listOrderItems){
        Boolean check = False;
        if(String.isBlank(listOrderItems[0].NE__OrderId__r.XC_OptyProjectId__c)){
            return check;
        }
        NE__Order__c order = new NE__Order__c();
        order.Id = listOrderItems[0].NE__OrderId__c;
        order.NE__FulfilmentStatus__c = Label.XC_CL_Order_StatusSent;
        order.NE__OrderStatus__c = Label.XC_CL_Order_StatusSent;
        order.XC_AssetsCreated__c = true;
        update order;
        NE.JS_RemoteMethods.order2asset(order.ID);
        List<project_cloud__Project__c> listProjects = [select id, XC_Configuration__c, ccpe_ocp__Opportunity__c from project_cloud__Project__c where id = :listOrderItems[0].NE__OrderId__r.XC_OptyProjectId__c];
        for(project_cloud__Project__c p :listProjects){
            p.XC_Configuration__c = listOrderItems[0].NE__OrderId__c;
        }
        //XC_UTIL_Sobject.updateListRecords(listProjects);
        update listProjects;
        check = true;
        return check;
    }

/*
    /**
  * @description Method to populare Result Wrapper for Error
  * @param rw - XC_UTIL_ResultWrapper
  * @param resultMessage - String
  * @return XC_UTIL_ResultWrapper
  */
    private static XC_UTIL_ResultWrapper populateWrapperFailedStopExecution(XC_UTIL_ResultWrapper rw, String resultMessage){
        rw.success = false;
        rw.resultMessage = resultMessage;
        rw.typeMessage = 'error';
        rw.executeNextStep = false;
        return rw;
    }


    /**
  * @description Method to populare Result Wrapper for Success
  * @param rw - XC_UTIL_ResultWrapper
  * @param resultMessage - String
  * @param typeMessage - String
  * @return XC_UTIL_ResultWrapper
  */
    private static void populateWrapperSuccess(XC_UTIL_ResultWrapper rw, String resultMessage, String typeMessage){
        rw.success = true;
        rw.resultMessage = resultMessage;
        rw.typeMessage = typeMessage;
    }


}
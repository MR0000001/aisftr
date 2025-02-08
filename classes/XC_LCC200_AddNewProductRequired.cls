/**
* @author dpalamides
* @date 15/07/2020
* @description: classes.XC_LCC200_AddNewProductRequired
*/


public without sharing class XC_LCC200_AddNewProductRequired {
    /**
      * @author dpalamides
      * @date Creation 22/06/2019
      * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
      * @description // wrapper class with @AuraEnabled and {get;set;} properties
      */

    public class ResultOtherPA{
        /** @description result operation */
        @AuraEnabled
        public boolean result{get;set;}
        /** @description message operation */
        @AuraEnabled
        public String message{get;set;}
        /** @description type message operation success/error */
        @AuraEnabled
        public String typeMessage{get;set;}
        /** @description title modal message */
        @AuraEnabled
        public String titleMessage{get;set;}
        /** @description NE_OrderItem__c.XC_WBE__c on commercial item choose */
        @AuraEnabled
        public String wbeElement{get;set;}
        /** @description NE_OrderItem__c.XC_costCenter__c on commercial item choose  */
        @AuraEnabled
        public String costCenter{get;set;}
    }

/**
    * @author dpalamides
    * @date Creation 15/07/2020
    * @description // get Country ConfigurationItem
    * @param woliId string
    * @return List<NE__OrderItem__c>
    */

    @AuraEnabled
    public static List<NE__OrderItem__c> getCommercialItemList(Id woliId){
        if(!Schema.sObjectType.WorkOrder.isAccessible() || !Schema.sObjectType.WorkOrderLineItem.isAccessible() || !Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            return null;
        }
        WorkOrderLineItem currWoli = [select id,XC_MaterialRequest__c, WorkOrder.XC_Configuration__c, WorkOrder.XC_Configuration_Item__c,
                                            XC_Project_Task__r.XC_OrderItem__c, status, RecordType.DeveloperName
                                    from WorkOrderLineItem where id = :woliId];

        String woliForCI = currWoli.RecordType.DeveloperName != null && currWoli.RecordType.DeveloperName.contains('_Good_Issue') && currWoli.XC_MaterialRequest__c != null ? currWoli.XC_MaterialRequest__c : currWoli.Id;

        WorkOrderLineItem woli = [select id,XC_MaterialRequest__c, WorkOrder.XC_Configuration__c, WorkOrder.XC_Configuration_Item__c,
                                         XC_Project_Task__r.XC_OrderItem__c, status
                                    from WorkOrderLineItem where id = :woliForCI];

        if(currWoli.status == 'Closed' || currWoli.status == 'Completed'){
            return null;
        }
        if(currWoli.WorkOrder.XC_Configuration__c == null && currWoli.WorkOrder.XC_Configuration_Item__c == null){
            return new List<NE__OrderItem__c>();
        }
        List<NE__OrderItem__c> commercialCI = new List<NE__OrderItem__c>();
        if(woli.XC_Project_Task__r.XC_OrderItem__c != null) {
            commercialCI = [select id, name, NE__ProdName__c from NE__OrderItem__c where (id = :woli.XC_Project_Task__r.XC_OrderItem__c or NE__Parent_Order_Item__c = :woli.XC_Project_Task__r.XC_OrderItem__c) and RecordType.DeveloperName != 'Technical_Item'];
        } else if(woli.WorkOrder.XC_Configuration_Item__c != null){
            commercialCI = [select id, name, NE__ProdName__c from NE__OrderItem__c where (id = :woli.WorkOrder.XC_Configuration_Item__c or NE__Parent_Order_Item__c = :woli.WorkOrder.XC_Configuration_Item__c) and RecordType.DeveloperName != 'Technical_Item'];
        } else {
            commercialCI = [select id, name, NE__ProdName__c from NE__OrderItem__c where NE__OrderId__c = :woli.WorkOrder.XC_Configuration__c and RecordType.DeveloperName != 'Technical_Item'];
        }
        /*Id workOrderDec = [select WorkOrder.RootWorkOrderId from workOrderLineItem WHERE Id = :woliId].workorder.RootWorkOrderId;
        system.debug('@@@@ getCommercialItemList - workOrderDec:' + workOrderDec);
        List<WorkOrder> woChildDEC = new List<WorkOrder>();
        if(Schema.sObjectType.WorkOrder.isAccessible()){
            woChildDEC = [select id, XC_Configuration_Item__c from WorkOrder where RootWorkOrderId =:workOrderDec ];
        }

        system.debug('@@@@ getCommercialItemList - woChildDEC:' + woChildDEC);
        List<String> idCommCIIds = new List<String>();
        if(woChildDEC.size()>0){
            for(WorkOrder wo: woChildDEC){
                system.debug('@@@@ getCommercialItemList - wo.XC_Configuration_Item__c:' + wo.XC_Configuration_Item__c);
                idCommCIIds.add(wo.XC_Configuration_Item__c);

            }
        }
        system.debug('@@@@ getCommercialItemList - idCommCIIds:' + idCommCIIds);
        List<NE__OrderItem__c> commercialCI = new List<NE__OrderItem__c>();
        if(Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            commercialCI=  [select Id, name from NE__OrderItem__c where id in:idCommCIIds];
        }
        system.debug('@@@@ getCommercialItemList - commercialCI:' + commercialCI);
        */

        return commercialCI;

    }


    /**
    * @author dpalamides
    * @date Creation 15/07/2020
    * @description // get Country ConfigurationItem
    * @param confItemComm id
    * @return LParamToGloviaSoli
    */

    @AuraEnabled
    public static ResultOtherPA getParamToGlovia(Id confItemComm){

        ResultOtherPA  param = new ResultOtherPA();
        param.result = false;
        system.debug('@@@@ getParamToGlovia - confItemComm:' + confItemComm);
        List<NE__OrderItem__c> confComm = new List<NE__OrderItem__c>();
        if(Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            confComm=[SELECT XC_WBE__c, XC_CMCostCenter__c from NE__OrderItem__c where id=:confItemComm];
            system.debug('@@@@ getParamToGlovia - conComm:' + confComm);

            for(NE__OrderItem__c ci : confComm){
                param.costCenter = ci.XC_CMCostCenter__c;
                param.wbeElement = ci.XC_WBE__c;
                system.debug('@@@@ getParamToGlovia - param.costCenter:' + param.costCenter);
                system.debug('@@@@ getParamToGlovia - param.wbeElement:' + param.wbeElement);

                if(ci.XC_WBE__c =='' && ci.XC_CMCostCenter__c ==''){

                    param.result = false;
                    param.message ='Operation failed!!! WBE element or costCenter missing';
                    param.titleMessage = 'Order Material';
                    param.typeMessage = 'Error';

                }else

                        param.result = true;


            }
            system.debug('@@@@ getParamToGlovia - param.result:' + param.result);
        }

        return param;
    }
}
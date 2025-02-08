/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date	18/04/2019
* @description XC_UTIL_Order_U - Method for XC_UTIL_Order
**/

public class XC_UTIL_Order_U {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Order_U');

    /**
	* @description Create a configuration (Fields B2W - FOR CYCLOMATIC COMPLEXITY WARNING)
    * @param wreq - XC_UTIL_Order.OrderIFWrapper
    * @param newOrder - NE__Order__c
	**/
    public static void createOrderForB2WFields(XC_UTIL_Order.OrderIFWrapper wreq, NE__Order__c newOrder) {
        //missing UniqueID

        newOrder.NE__Version__c = 1;
        Decimal recurringChargeTotal = (wreq.TotalRecurringCharge != null) ? Decimal.ValueOf(wreq.TotalRecurringCharge) : null;
        Decimal oneTimeFeeTotal = (wreq.TotalOneTimeFee != null) ? Decimal.ValueOf(wreq.TotalOneTimeFee) : null;
        Map<String, Object> mapOrderWrapper = new Map<String,Object>{'NE__OptyId__c' =>  wreq.OpportunityId,
                                                        'NE__AccountId__c' => wreq.AccountId,
                                                        'NE__BillAccId__c' => wreq.AccountId,
                                                        'NE__Contract_Account__c' =>  wreq.ContractAccount,
                                                        'NE__Service_Account_Asset__c' => wreq.ServiceAccountAsset,
                                                        'NE__Billing_Account_Asset__c'=> wreq.BillingAccountAsset,
                                                        'NE__Description__c' => wreq.OrderDescription,
                                                        'NE__Recurring_Charge_Total__c' => recurringChargeTotal,
                                                        'NE__One_Time_Fee_Total__c' => oneTimeFeeTotal
                                                        };
        for(String key : mapOrderWrapper.keySet()){
            if(mapOrderWrapper.get(key) != null){
                newOrder.put(key, mapOrderWrapper.get(key));
            }
        }      
        
    }

    /**
	* @description Create a configuration (FOR CYCLOMATIC COMPLEXITY WARNING)
    * @param wreq - XC_UTIL_Order.OrderIFWrapper
    * @param newOrder - NE__Order__c
	**/
    public static void createOrderForPreferenceFields(XC_UTIL_Order.OrderIFWrapper wreq, NE__Order__c newOrder) {
        
        system.debug('test: '+wreq.BillingAddress);

        Map<String, Object> mapOrderWrapper = new Map<String,Object>{'XC_POD__c' =>  wreq.PointOfDelivery,
                                                                    'XC_Order_Tracking__c' => wreq.OrderTracking,
                                                                    'XC_Mode_of_cancellation__c' =>  wreq.ModeOfcancellation,
                                                                    'XC_Type_of_cancellation__c' =>wreq.TypeOfcancellation,
                                                                    'XC_DeliveryType__c'=> wreq.DeliveryType,
                                                                    'XC_InstallationAddress__c' => wreq.InstallationAddress,
                                                                    'XC_OrderBillingAddress__c' => wreq.BillingAddress
                                                                    };
        for(String key : mapOrderWrapper.keySet()){
            if(mapOrderWrapper.get(key) != null){
                newOrder.put(key, mapOrderWrapper.get(key));
            }
        }      

    }

    /**
	* @description Create a configuration (FOR CYCLOMATIC COMPLEXITY WARNING)
    * @param wreq - XC_UTIL_Order.OrderIFWrapper
    * @param newOrder - NE__Order__c
	**/
    public static void createOrderForApprovalFields(XC_UTIL_Order.OrderIFWrapper wreq, NE__Order__c newOrder) {

         Map<String, Object> mapOrderWrapper = new Map<String,Object>{'XC_PracticeNumber__c' =>  wreq.FinancialPracticeNumber,
                                                                    'XC_FinancialApproval__c' => wreq.FinancialApproval,
                                                                    'XC_PracticeStatus__c' => wreq.PracticeStatus,
                                                                    'XC_FinancialRejectReason__c'=> wreq.FinancialRejectReason,
                                                                    'XC_Compliance_Approval__c' => wreq.ComplianceApproval,
                                                                    'XC_ComplianceRejectReason__c' => wreq.ComplianceRejectReason
                                                                    };
        for(String key : mapOrderWrapper.keySet()){
            if(mapOrderWrapper.get(key) != null){
                newOrder.put(key, mapOrderWrapper.get(key));
            }
        }      

    }
}
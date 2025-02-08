public class XC_LCC_ConfItemHierController {
    
	@AuraEnabled
	public static List<NE__OrderItem__c> getConfs(String orderId) {
    List<NE__OrderItem__c> confs=  [SELECT id, XC_Product2Id__r.ProductCode, XC_Product2Id__r.Name, NE__ProdId__r.Name,NE__Root_Order_Item__c,
    									Name, NE__OrderId__c, NE__Qty__c, XC_Product2Id__c, XC_CostFull_Life__c, XC_RevenueFullLife__c, NE__Parent_Order_Item__c, XC_ParentCommercialItem__c,
                                    	XC_CapexFullLife__c, NE__StartDate__c, NE__EndDate__c,(select id, Name, NE__Value__c from NE__Order_Item_Attributes__r)
                                    FROM NE__OrderItem__c 
                                    WHERE NE__OrderId__c =: orderId];
    
		Map<Integer, NE__OrderItem__c> orderOIs = new Map<Integer, NE__OrderItem__c>();
        List<NE__OrderItem__c> oisSort = new List<NE__OrderItem__c>();
		
        Integer index = 0;
        List<NE__OrderItem__c> roots = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> childs = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> techs = new List<NE__OrderItem__c>();
        
        for(NE__OrderItem__c oi: confs) {
        	System.debug(oi);

            if(oi.NE__Parent_Order_Item__c == null && oi.XC_ParentCommercialItem__c == null){
                roots.add(oi);
            }
            if(oi.NE__Parent_Order_Item__c!=null && oi.XC_ParentCommercialItem__c == null){
                childs.add(oi);
			}
            if(oi.NE__Parent_Order_Item__c==null && oi.XC_ParentCommercialItem__c != null){
                techs.add(oi);
            }
    	} //end loop 1
        
        for(NE__OrderItem__c root : roots){
			orderOIs.put(index,root);
            for(NE__OrderItem__c child : childs){
                if(child.NE__Parent_Order_Item__c == root.Id){
                    index++;
                    orderOIs.put(index,child);
                    for(NE__OrderItem__c tech : techs){
                        if(tech.XC_ParentCommercialItem__c == child.Id){
                            index++;
                            orderOIs.put(index,tech);
                        }
                    } //end loop techs
                }
            } //end loop childs
            index++;
        } //end loop roots
        
        for(Integer i : orderOIs.keySet()){
            oisSort.add(orderOIs.get(i));
        }
        
        return oisSort;
    }
    
    //Start CR-758 R2
    @AuraEnabled
    public static Integer checkCommercial(String orderId){
        Integer result = 0;
        NE__Order__c ord = getOrder(orderId);
        if(ord!=null && ord.NE__OptyId__r!=null && ord.XC_Segment__c == 'B2G'){
            result = checkCommercialType(ord.NE__OptyId__r.XC_Commercial_Contract_Type__c);
        }
        return result;
    }
    
    @AuraEnabled
    public static NE__Order__c getOrder(String orderId){
        NE__Order__c ord = [SELECT id, XC_Segment__c, XC_LegalEntity__c, NE__OptyId__r.XC_Commercial_Contract_Type__c FROM NE__Order__c WHERE id =:orderId];
        return ord;
    }
 	
    @AuraEnabled
    public static Integer checkCommercialType(String commType){
        Integer result = 0;
        if(commType != null && commTypes1.contains(commType)) result = 1;
        if(commType != null && commTypes2.contains(commType)) result = 2;
        return result;
    }
    
    public static List<String> commTypes1 = new List<String>{
        'Spot Sales works',
        'Extracanone works PF_Gare_Consip',
        'Spot Sales works with deferred payment',
		'Investiments on owned assets',
		'Investiments on owned assets ERP',
		'Investiments on third parties assets',
		'Spot Sales material supply',
        'Spot sales Upselling',
        'Investiments on assets',
        'Spot Sales Chargers_depots',
        'Green Ports',
        'Cold Ironing'
    };
       
	public static List<String> commTypes2 = new List<String>{
        'OM Projects without energy',
        'Capex Intensive Projects with energy ESCO',
        'Capex Intensive Projects without energy',
        'Spot Sales Works_OM',
        'Asset renting',
        'OM Projects with energy',
        'Contracts of just Energy',
        'Integrated offer Investiments on assets_OM'            
    };   
    //End CR-758 R2
}
public with sharing class XC_IN058_PredefinedMaintenancePlan {
  
    public class InputWrapper {

        /** The String. */
        @Invocablevariable
        public String stepId;

    }
  
    /**
     * @author nicola arrigo - narrigo@deloitte.it
     * @description maintenancePlan manages the  provisioning step Maintenance Plan 
     * @param inputWrapperList the input wrapper list
     */
    @InvocableMethod 
    public static void maintenancePlan(List<InputWrapper> inputWrapperList){
    List<string> listStepId=new List<string>();
    for(InputWrapper iw:inputWrapperList){
        listStepId.add(iw.stepId);
    } 
    XC_Provisioning_Step__c step=[select id,XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__r.NE__AccountId__c,
                                  XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c,
                                  XC_Configuration_Item__r.XC_Segment__c,
                                  XC_Configuration_Item__r.NE__OrderId__c 
                                    from XC_Provisioning_Step__c 
                                    where id IN:listStepId limit 1];
        WorkType woPlannedMaintenance= [select id,XC_Product_Subtype__c,XC_LegalEntity__c, XC_Segment__c,
                                        XC_WorkTypeCategory__c  
                                        from WorkType 
                                        where XC_Segment__c=:step.XC_Configuration_Item__r.XC_Segment__c and 
                                              XC_LegalEntity__c=:step.XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c and
                                          name='Planned Maintenance - Generic' limit 1];
     List<Contract> con=[select id,StartDate,EndDate from contract 
                            where XC_Configurations__c=:step.XC_Configuration_Item__r.NE__OrderId__c];                              
     NE__OrderItem__c confItemMaintenance=[select id,XC_Product_Subtype__c, NE__Root_Order_Item__c from NE__OrderItem__c 
                                                                                            where XC_Product_Subtype__c='Maintenance' and  
                                                                                            NE__Root_Order_Item__c=:step.XC_Configuration_Item__c];
   NE__Order_Item_Attribute__c  frequencyAttribute=[select id,NE__Order_Item__c, name,NE__Value__c 
                                                                                            from NE__Order_Item_Attribute__c
                                                                                              where 
                                                                                              name='Frequency' and 
                                                                                          NE__Order_Item__c=:confItemMaintenance.id];                                                                                          
    NE__Order_Item_Attribute__c  frequencyTypeAttribute=[select id,NE__Order_Item__c, name,NE__Value__c 
                                                              from NE__Order_Item_Attribute__c
                                                                where 
                                                                name='Frequency Type' and 
                                                            NE__Order_Item__c=:confItemMaintenance.id];  
      Contact conc=[select id from contact where 
                                AccountId=:Step.XC_Configuration_Item__r.NE__OrderId__r.NE__AccountId__c and 
                                XC_PrimaryContact__c=true];
      integer freq=integer.valueof(frequencyAttribute.NE__Value__c );                                                      
      string freqType= frequencyTypeAttribute.NE__Value__c;
      Integer days=calculateDays(freq,freqType);
      WorkOrder woInstall= [Select id,XC_WorkTypeLabel__c,XC_WorkTypeCategory__c,OwnerId,XC_Configuration_Item__c,
                               XC_LegalEntity__c,XC_Address__c,XC_Segment__c
                               from workorder 
                              where XC_WorkTypeCategory__c='Installation' and  XC_Configuration_Item__c=:step.XC_Configuration_Item__c
                            limit 1];
      
      MaintenancePlan maintenancePlan = new MaintenancePlan();
      maintenancePlan.WorkTypeId=woPlannedMaintenance.id;
      maintenanceplan.StartDate=con[0].StartDate;
      maintenancePlan.XC_LegalEntity__c=woInstall.XC_LegalEntity__c;
      maintenancePlan.XC_Address__c=woInstall.XC_Address__c;
      maintenancePlan.XC_Segment__c=woInstall.XC_Segment__c;  
      maintenancePlan.EndDate=con[0].EndDate;
       date StartDate=con[0].StartDate;
      date EndDate=con[0].EndDate;
      integer contractDurantion=startDate.daysBetween(EndDate);
      /*maintenancePlan.Frequency=freq;
      maintenancePlan.FrequencyType=frequencyTypeAttribute.NE__Value__c;*/
      maintenancePlan.Frequency=days;
      maintenancePlan.FrequencyType='Days';
      maintenancePlan.NextSuggestedMaintenanceDate=maintenanceplan.StartDate.addDays(days);
      maintenancePlan.AccountId=step.XC_Configuration_Item__r.NE__OrderId__r.NE__AccountId__c;
      maintenancePlan.ContactId=conc.id;
      integer yearDuration=365/contractDurantion;
      //maintenancePlan.GenerationTimeframe=14;
      maintenancePlan.GenerationTimeframe=yearDuration;
      maintenancePlan.GenerationTimeframeType='Years';
      maintenancePlan.DoesAutoGenerateWorkOrders=true;
      system.debug('GenerationTimeFrame'+' '+maintenancePlan.GenerationTimeframe);
      maintenancePlan.OwnerId=woInstall.OwnerId;
      maintenancePlan.XC_Contract__c=con[0].id;
      maintenancePlan.WorkOrderGenerationMethod='WorkOrderLineItemPerAsset';
      maintenancePlan.SvcApptGenerationMethod='SvcApptPerWorkOrder';
      insert maintenancePlan;
      // Maintenance Asset
     /* List<WorkType> woTypeList=[Select id,XC_Segment__c, XC_LegalEntity__c, XC_Product_Subtype__c, XC_WorkTypeCategory__c 
                                  from WorkType];*/ 
     /* List<Asset> assetTechList=[select id,TAM_IsLogical__c,TAM_IsTechnical__c,XC_Product_Subtype__c from Asset 
                                 where 
                                 XC_Configuration_Item__r.NE__OrderId__c=:step.XC_Configuration_Item__r.NE__OrderId__c and 
                                 TAM_IsTechnical__c=true];*/   
      List<WorkOrderLineItem> WoliTechAsset=[select id,WorkOrderId,
                                            (select id, TAM_Asset__c, TAM_Asset__r.TAM_IsTechnical__c  from Products_Consumed__r) from WorkOrderLineItem 
                                            where 
                                            (XC_WOLIType__c='Technical Asset') and
                                            WorkOrderId=:woInstall.id
                                            ];
    List<id> AssetId=new List<id>();
       List<MaintenanceAsset> assetsListMaintenance=new List<MaintenanceAsset>();
       for(WorkOrderLineItem woli:WoliTechAsset){
        for( XC_ProductConsumed__c prodCons:woli.Products_Consumed__r){
         AssetId.add(prodCons.TAM_Asset__c);
        }
      }  
       List<Asset> assetTechList=new List<Asset>();
       if(!AssetId.isempty()){
          
       assetTechList=[select id,TAM_IsLogical__c,TAM_IsTechnical__c,XC_Product_Subtype__c,XC_LegalEntity__c from Asset 
                                 where  
                                 TAM_IsTechnical__c=true and id IN:AssetId];   
       }                             
     List<string> productSubTypeList=new List<string>();
   if(assetTechList.size()>0){
     for(Asset a:assetTechList){
        productSubTypeList.add(a.XC_Product_Subtype__c);
     }
     system.debug('subtypeList'+' '+productSubTypeList);
     List<WorkType> wtList=[select id,XC_Segment__c, XC_LegalEntity__c, XC_Product_Subtype__c, XC_WorkTypeCategory__c 
                                  from WorkType 
                                  where XC_Segment__c=:step.XC_Configuration_Item__r.XC_Segment__c and
                                        XC_LegalEntity__c=:step.XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c and 
                                        XC_WorkTypeCategory__c='Planned Maintenance' and 
                                        XC_Product_Subtype__c IN:productSubTypeList
                                  ];
    system.debug('WorkTypeList'+' '+wtList);                              
    Map<String, Worktype>WorkTypeMapCategory= getWorkTypeMapCategory(wtList);                              
    for(Asset ass:assetTechList){
        MaintenanceAsset assMaintenance=new MaintenanceAsset();
        assMaintenance.AssetId=ass.id;
        String key='Planned Maintenance'+'_'+step.XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c+'_';
        key+=step.XC_Configuration_Item__r.XC_Segment__c;
        string subType=ass.XC_Product_Subtype__c;
        String tmpKey = key + subType;
        assMaintenance.MaintenancePlanId=maintenancePlan.id;
        system.debug('keyMap'+' '+tmpKey);
        system.debug('MapWorkType'+' '+WorkTypeMapCategory.get(tmpKey));
        if(!wtList.isempty() &&
            WorkTypeMapCategory.get(tmpKey)!=null){
            worktype wt=WorkTypeMapCategory.get(tmpKey);
            assMaintenance.WorkTypeId=wt.Id;
        } 
        assetsListMaintenance.add(assMaintenance);
      }
      if(!assetsListMaintenance.isempty()){
          system.debug('List Asset Maintenance'+' '+ assetsListMaintenance.size());
          insert assetsListMaintenance;
      }
     }
    }
    public static integer calculateDays(integer freq,string freqType){
         integer days;
         Long dValue;
        if(freqType=='Days'){
           days=freq;
        }else if(freqType=='Weeks'){
            dValue=Math.roundToLong(7/freq);
            days=dValue.intValue();       
        }else if(freqType=='Months'){
            dValue=Math.roundToLong(30/freq);
            days=dValue.intValue();
        }else if(freqType=='Years'){
            dValue=Math.roundToLong(365/freq);
            days=dValue.intValue();
        }
        return days;    
    }
    private static Map<String, Worktype> getWorkTypeMapCategory(List<WorkType> wtList){
        system.debug('WorkTypeList'+' '+wtList);
        Map<String, WorkType> workTypeMapCategory = new Map<String, WorkType>();
        for (WorkType wt : wtList) {
            List<String> listKeys = new List<String>();
            String key = wt.XC_WorkTypeCategory__c + '_' + wt.XC_LegalEntity__c+'_'+wt.XC_Segment__c;
            if(wt.XC_Product_Subtype__c != null){
                system.debug('ProdSubType'+' '+wt.XC_Product_Subtype__c);
                String tmpKey = key + wt.XC_Product_Subtype__c;
                system.debug('tmpKey'+' '+' '+tmpKey);
                listKeys.add(tmpKey); 
                /*for (String subType : wt.XC_Product_Subtype__c.split(';')) { 
                    String tmpKey = key + subType;
                    if(wt.XC_CoverageSkill__c != null){
                        tmpKey += wt.XC_CoverageSkill__c;
                    } 
                    if(wt.XC_CoverageParentSkill__c != null){
                        tmpKey += wt.XC_CoverageParentSkill__c;
                    }
                    listKeys.add(tmpKey);
                }*/
            }else {
                listKeys.add(key);
            }

            for(String keyJ : listKeys){
                system.debug('key Map Worktype'+' '+keyJ);
                workTypeMapCategory.put(keyJ, wt);
            }
            
        }
        System.debug('@@@ workTypeMapCategory: ' + workTypeMapCategory);
        return workTypeMapCategory;
    }
}
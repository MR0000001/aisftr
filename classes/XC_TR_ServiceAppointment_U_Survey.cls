/**
 * @author Andrea DI Cicco
 * @date Creation 27/01/2021
 * @description XC_TR_ServiceAppointment_U_Survey – Create survey for B2B
 */
public class XC_TR_ServiceAppointment_U_Survey {
    
    public static void createSurvey(Map<Id, ServiceAppointment> mapOld, Map<Id, ServiceAppointment> mapNew){
        System.debug('@@@@@@ CREATE SURVEY');
       	List<String> woForSurveyId = new List<String>();
        List<XC_Customer_Interaction__c> surveyList = new List<XC_Customer_Interaction__c>();
        for(ServiceAppointment sa : mapNew.values()){
            Boolean check = (sa.XC_Segment__c == 'B2B' || sa.XC_Segment__c == 'B2G') && sa.status == 'Completed' &&  sa.XC_WorkTypeLabel__c  != null && (sa.XC_WorkTypeLabel__c.contains('Maintenance')|| sa.XC_WorkTypeLabel__c.contains( 'Malfunctioning')|| sa.XC_WorkTypeLabel__c.contains( 'Installation'));
            if(check){
                System.debug('@@@@@@ INTO CHECK');
                woForSurveyId.add(sa.ParentRecordId);
            }
        } 
        System.debug('XC_TR_ServiceAppointment_U_Survey ' + woForSurveyId);
        if(woForSurveyId.isEmpty()){
            return;
        }
        List<WorkOrder> woInfo = new List<WorkOrder>();
        woInfo = [Select id, XC_WorkTypeLabel__c, AssetId, Asset.TAM_IsLogical__c, Asset.TAM_BusinessLine__c, Asset.TAM_IsTechnical__c, Asset.TAM_CommercialAsset__c, BusinessLine__c,  Asset.NE__CatalogItem__c,XC_Opportunity__c , XC_Configuration__c, XC_Configuration_Item__c , asset.NE__ProdId__c, asset.NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name,asset.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name, Asset.NE__CatalogItem__r.XC_ProductLine__c,asset.TAM_CommercialAsset__r.NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name,asset.TAM_CommercialAsset__r.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name, Asset.TAM_CommercialAsset__r.NE__CatalogItem__r.XC_ProductLine__c, ContactId, AccountId, Contact.Name, Contact.Email, Contact.XC_Preferredlanguageofcontact__c, XC_LegalEntity__c, XC_Segment__c,  asset.XC_Product_Name_LIC__c from WorkOrder where ID IN: woForSurveyId]; //XC_ToProject__c = false and
        System.debug('@@@@ woForSurveyId ' + woInfo);
        if(woInfo == null || woInfo.isEmpty()){
            return;
        }
        for(WorkOrder wo : woInfo){
            
            //if(wo.AssetId == null || wo.Asset.NE__CatalogItem__c == null){
            //    continue;
            //}
            XC_Customer_Interaction__c ci = populateSurvey(wo, mapNew.values());
            ci.XC_Communication_Type__c = 'Survey_Post_Maintenance';
            if(wo.XC_WorkTypeLabel__c != null && wo.XC_WorkTypeLabel__c.contains('Malfunctioning')){
                if (wo.asset.TAM_IsLogical__c==true || wo.asset.TAM_IsTechnical__c==true){
                    if(wo.asset.TAM_CommercialAsset__r.NE__CatalogItem__r.XC_ProductLine__c == 'E700'  || wo.asset.TAM_CommercialAsset__r.NE__CatalogItem__r.XC_ProductLine__c == 'E400'){
                        ci.XC_SurveyId__c = 'Survey_Maintenance_Extraordinary';
                    }else if(wo.asset.TAM_CommercialAsset__r.NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name == 'Storage' || wo.asset.TAM_CommercialAsset__r.NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name =='Distributed Energy' ||  wo.asset.TAM_CommercialAsset__r.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name ==  'Storage' || wo.asset.TAM_CommercialAsset__r.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name ==  'Distributed Energy' ){
                        ci.XC_SurveyId__c = 'Survey_Maintenance_Extraordinary';
                    }

                }else{
                if(wo.asset.NE__CatalogItem__r.XC_ProductLine__c == 'E700'  || wo.asset.NE__CatalogItem__r.XC_ProductLine__c == 'E400'){
                    ci.XC_SurveyId__c = 'Survey_Maintenance_Extraordinary';
                }else if(wo.asset.NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name == 'Storage' || wo.asset.NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name =='Distributed Energy' ||  wo.asset.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name ==  'Storage' || wo.asset.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name ==  'Distributed Energy' ){
                    ci.XC_SurveyId__c = 'Survey_Maintenance_Extraordinary';
                }
            }
            }else if(wo.XC_WorkTypeLabel__c != null && wo.XC_WorkTypeLabel__c.contains('Maintenance')){
                if (wo.asset.TAM_IsLogical__c==true || wo.asset.TAM_IsTechnical__c==true){
                    if(wo.asset.TAM_CommercialAsset__r.NE__CatalogItem__r.XC_ProductLine__c == 'E700'  || wo.asset.TAM_CommercialAsset__r.NE__CatalogItem__r.XC_ProductLine__c == 'E400'){
                        ci.XC_SurveyId__c = 'Survey_Maintenance';
                    }else if(wo.asset.TAM_CommercialAsset__r.NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name == 'Storage' || wo.asset.TAM_CommercialAsset__r.NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name =='Distributed Energy' ||  wo.asset.TAM_CommercialAsset__r.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name ==  'Storage' || wo.asset.TAM_CommercialAsset__r.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name ==  'Distributed Energy'){
                        ci.XC_SurveyId__c = 'Survey_Maintenance_Ordinary';
                    }
                }
                else{
                if(wo.asset.NE__CatalogItem__r.XC_ProductLine__c == 'E700'  || wo.asset.NE__CatalogItem__r.XC_ProductLine__c == 'E400'){
                    ci.XC_SurveyId__c = 'Survey_Maintenance';
                }else if(wo.asset.NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name == 'Storage' || wo.asset.NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name =='Distributed Energy' ||  wo.asset.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name ==  'Storage' || wo.asset.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name ==  'Distributed Energy'){
                    ci.XC_SurveyId__c = 'Survey_Maintenance_Ordinary';
                }
            }
            }else if(wo.XC_WorkTypeLabel__c != null && wo.XC_WorkTypeLabel__c.contains('Installation')){
                Boolean checkType=false;
                if (wo.asset.TAM_IsLogical__c==true || wo.asset.TAM_IsTechnical__c==true){
                    checkType = wo.asset.TAM_CommercialAsset__r.NE__CatalogItem__r.XC_ProductLine__c == 'E700'  || wo.asset.TAM_CommercialAsset__r.NE__CatalogItem__r.XC_ProductLine__c == 'E400' || wo.asset.TAM_CommercialAsset__r.NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name == 'Storage' || wo.asset.TAM_CommercialAsset__r.NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name =='Distributed Energy'|| wo.asset.TAM_CommercialAsset__r.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name ==  'Storage' || wo.asset.TAM_CommercialAsset__r.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name ==  'Distributed Energy';
                }else{
                    checkType = wo.asset.NE__CatalogItem__r.XC_ProductLine__c == 'E700'  || wo.asset.NE__CatalogItem__r.XC_ProductLine__c == 'E400' || wo.asset.NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name == 'Storage' || wo.asset.NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name =='Distributed Energy'|| wo.asset.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name ==  'Storage' || wo.asset.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.Name ==  'Distributed Energy';
                }
                
                if(checkType){
                    ci.XC_Communication_Type__c = 'Survey_Installation';
                	ci.XC_SurveyId__c = 'Survey_Installation';  
                }
            }
           	
			System.debug('XC_TR_ServiceAppointment_U_Survey '+ ci);    
            if(ci.XC_SurveyId__c != null){
                surveyList.add(ci);
            }
        }
        System.debug('@@@@ SURVEYLIST '+ surveyList);
        XC_UTIL_DML.insertRecords(surveyList);
    }
    
    public static XC_Customer_Interaction__c populateSurvey(WorkOrder wo, List<ServiceAppointment> sa ){
                XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
                ci.XC_OpportunityId__c = wo.XC_Opportunity__c;
                ci.XC_ConfigurationItem__c = wo.XC_Configuration_Item__c ;
                ci.XC_OrderId__c = wo.XC_Configuration__c;
                ci.XC_ProductId__c = wo.AssetId != null? wo.asset.NE__ProdId__c : null;
                ci.XC_ContactId__c = wo.ContactId;
                ci.XC_AccountId__c = wo.AccountId;
                ci.XC_Recipient__c = wo.ContactId != null? wo.Contact.Name : null;
                ci.XC_WorkOrderId__c=wo.Id;
                ci.XC_Email__c = wo.ContactId != null? wo.Contact.Email : null;
                ci.XC_Preferredlanguageofcontact__c = wo.ContactId != null? wo.Contact.XC_Preferredlanguageofcontact__c : null;
                ci.XC_Channel__c = 'Email';
                ci.XC_LegalEntity__c = wo.XC_LegalEntity__c;
                ci.XC_Segment__c = wo.XC_Segment__c;
                ci.XC_BusinessLine__c = wo.Asset.TAM_BusinessLine__c;
                return ci;
    }
    public static XC_Customer_Interaction__c populateSurvey(WorkOrder wo, List<ServiceAppointment> sa, String communicationType ){
                XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
                ci.XC_OpportunityId__c = wo.XC_Opportunity__c;
                ci.XC_ConfigurationItem__c = wo.XC_Configuration_Item__c ;
                ci.XC_OrderId__c = wo.XC_Configuration__c;
                ci.XC_ProductId__c = wo.AssetId != null? wo.asset.NE__ProdId__c : null;
                ci.XC_ContactId__c = wo.ContactId;
                ci.XC_AccountId__c = wo.AccountId;
                ci.XC_Recipient__c = wo.ContactId != null? wo.Contact.Name : null;
                ci.XC_WorkOrderId__c=wo.Id;
                ci.XC_Email__c = wo.ContactId != null? wo.Contact.Email : null;
                ci.XC_Preferredlanguageofcontact__c = wo.ContactId != null? wo.Contact.XC_Preferredlanguageofcontact__c : null;
                ci.XC_Channel__c = 'Email';
                ci.XC_LegalEntity__c = wo.XC_LegalEntity__c;
                ci.XC_Segment__c = wo.XC_Segment__c;
                ci.XC_BusinessLine__c = wo.Asset.TAM_BusinessLine__c;
                return ci;
    }
}
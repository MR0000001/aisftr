/*
 * The Class XC_TR_Campaignmember_U_CheckVoucher.
 * @author Simone Trenta - strenta@deloitte.it , Giuseppe Di Bonito - gdibonito@deloitte.it
 * @date Creation 06/08/2019
 * @date Modification 22/08/2019 Giuseppe Di Bonito - gdibonito@deloitte.it
 * @description XC_TR_CampaignMember_U_CheckVoucher multiple check on the voucher. The methods are used for the campaign member trigger before insert and for the campaign trigger after update
 */
public with sharing class XC_TR_CampaignMember_U_CheckVoucher {

    /**
     * Update CampaignMember Fields
     * @description CampaignMember Before Insert and Campaign After Update. 
     * @param listNew the list new
     */
    public static void updateCampaignMemberFields(List<CampaignMember> listNew){

        List<Id> campId = new List<Id>(); 
        for(CampaignMember newCampM : listNew) {
            campId.add(newCampM.campaignId);
        }

        //Query on the voucher fields assigned to the campaign
        Map<id,Campaign> mapCamp = new Map<id,Campaign>([
            SELECT 
            id, 
            XC_Code__c, 
            XC_Voucher__c, 
            IsActive, 
            //When the voucher on the campaign is of Individual type we need all the fields to create the childs
            XC_Voucher__r.RecordTypeId , 
            XC_Voucher__r.Name ,
            XC_Voucher__r.XC_Account__c , 
            XC_Voucher__r.XC_AccountType__c, 
            XC_Voucher__r.XC_Amount__c , 
            XC_Voucher__r.XC_Billing_Model__c , 
            XC_Voucher__r.XC_BusinessModel__c, 
            XC_Voucher__r.XC_Catalog__c , 
            XC_Voucher__r.XC_CommercialModel__c , 
            XC_Voucher__r.XC_CompanyCode__c , 
            XC_Voucher__r.XC_ConcatenationCode__c , 
            XC_Voucher__r.XC_Contact__c , 
            XC_Voucher__r.XC_ContractType__c, 
            XC_Voucher__r.XC_CostCenter__c , 
            XC_Voucher__r.XC_EndDate__c , 
            XC_Voucher__r.XC_Family__c, 
            XC_Voucher__r.XC_GenerateMultipleVoucher__c , 
            XC_Voucher__r.XC_HasBeenProcessedForDeactivation__c , 
            XC_Voucher__r.XC_InvoiceDescription__c, 
            XC_Voucher__r.XC_Lead__c, 
            XC_Voucher__r.XC_LegalEntity__c , 
            XC_Voucher__r.XC_NumberOfQuotas__c, 
            XC_Voucher__r.XC_Order__c , 
            XC_Voucher__r.XC_ParentVoucher__c, 
            XC_Voucher__r.XC_Product__c , 
            XC_Voucher__r.XC_ProductCategory__c , 
            XC_Voucher__r.XC_ProductLine__c, 
            XC_Voucher__r.XC_ProductService__c , 
            XC_Voucher__r.XC_PurseExpirationDate__c , 
            XC_Voucher__r.XC_PurseExpirationMonths__c, 
            XC_Voucher__r.XC_RecordTypeName__c , 
            XC_Voucher__r.XC_SalesChannel__c, 
            XC_Voucher__r.XC_StartDate__c, 
            XC_Voucher__r.XC_Status__c, 
            XC_Voucher__r.XC_Territories__c , 
            XC_Voucher__r.XC_Territory__c , 
            XC_Voucher__r.XC_Type_of_Discount__c , 
            XC_Voucher__r.XC_Unlimited__c , 
            XC_Voucher__r.XC_Uses__c , 
            XC_Voucher__r.XC_Usage_Counter__c ,
            XC_Voucher__r.XC_Voucher_To_Be_Created__c,
            XC_Voucher__r.XC_VoucherCode__c ,
            XC_Voucher__r.XC_VoucherLifetime__c,
                (SELECT Id, CampaignId FROM CampaignMembers)
            FROM Campaign
            WHERE id in: campId]);


        /* //USE IN CASE OF MASSIVE IMPORTS WITH DATALOADER
        Set<Campaign> uniqueCamp = new Set<Campaign>();
        uniqueCamp.addAll(mapCamp.values());
        System.debug(mapCamp.values());
        System.debug(uniqueCamp);
        
        for (Campaign uCam : uniqueCamp) {
            Set<CampaignMember> checkCampM = new Set<CampaignMember>();
            for (CampaignMember campM : listNew) {
                if (uCam.Id == campM.campaignId){
                    checkCampM.add(campM);
                }
            } 
            checkCampM.addAll(mapCamp.get(uCam.id).CampaignMembers);
            if (mapCamp.get(uCam.id).XC_Voucher__r.XC_RecordTypeName__c == 'Campaign Individual Voucher' && checkCampM.size() > mapCamp.get(uCam.id).XC_Voucher__r.XC_Voucher_To_Be_Created__c){
                System.debug(mapCamp.get(uCam.id).XC_Voucher__r.XC_Voucher_To_Be_Created__c);
                System.debug(checkCampM.size());
                System.debug('@@uCam : '+checkCampM);
                uCam.addError('Errore! Non ci sono abbastanza voucher.');
                //Campaign actualRecord = Trigger.oldMap.get(uCam.Id);
                //actualRecord.adderror('Errore! Non ci sono abbastanza voucher.');
            }  
        }*/


        //In case of individual voucher check if we added too many campaign members or if we updated the campaign with a voucher that not support all the campaign members that are already on the campaign
        Set<Id> myset = new Set<Id>();
        Set<Id> myset2 = new Set<Id>();
        for (CampaignMember cm : mapCamp.get(campId.get(0)).CampaignMembers){
            myset.add(cm.id); 
            myset2.add(cm.id);
        }
        if (mapCamp.get(campId.get(0)).XC_Voucher__r.XC_RecordTypeName__c == 'Campaign Individual Voucher'){
            for (CampaignMember cam : listNew){
                myset.add(cam.id);
                if (myset.size()>mapCamp.get(campId.get(0)).XC_Voucher__r.XC_Voucher_To_Be_Created__c){

                    if (myset2.size()==myset.size()){
                        //handle after update camapaign
                        throw new DmlException('Errore! Non ci sono abbastanza voucher.');
                    } else {
                        cam.addError('Errore! Non ci sono abbastanza voucher.');  
                    }
                }
            } 
        }

        List<XC_Voucher__c> voucChild = new List<XC_Voucher__c>(); 
        
        for(CampaignMember newCampM : listNew) {
            
            if (mapCamp.get(newCampM.campaignId).isActive){
                newCampM.addError('Non puoi aggiungere campaign member se la campagna è attiva');

            } else if (mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_RecordTypeName__c == 'Campaign General Voucher'){
                newCampM.XC_Voucher__c = mapCamp.get(newCampM.campaignId).XC_Voucher__c;
                newCampM.XC_VoucherCode__c = mapCamp.get(newCampM.campaignId).XC_Code__c;

            } else if (mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_RecordTypeName__c == null){
                newCampM.XC_Voucher__c = null;
                newCampM.XC_VoucherCode__c = null;

            } else if (mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_RecordTypeName__c == 'Campaign Individual Voucher'){ 
                //empty voucher object to fill to create a voucher child
                XC_Voucher__c v = new XC_Voucher__c();

                //parent lookup
                v.XC_ParentVoucher__c = mapCamp.get(newCampM.campaignId).XC_Voucher__c; 
                
                //contact or lead lookup
                v.XC_Contact__c  = newCampM.ContactId;
                v.XC_Lead__c = newCampM.LeadId;
                
                //fields from the parent
                v.RecordTypeId = mapCamp.get(newCampM.campaignId).XC_Voucher__r.RecordTypeId;
                v.Name = mapCamp.get(newCampM.campaignId).XC_Voucher__r.Name;
                v.XC_Account__c = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_Account__c;
                v.XC_AccountType__c = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_AccountType__c;
                v.XC_Amount__c  = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_Amount__c;
                v.XC_Billing_Model__c  = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_Billing_Model__c;
                v.XC_BusinessModel__c = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_BusinessModel__c;
                v.XC_Catalog__c  = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_Catalog__c;
                v.XC_CommercialModel__c  = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_CommercialModel__c;
                v.XC_CompanyCode__c  = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_CompanyCode__c;
                v.XC_ConcatenationCode__c  = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_ConcatenationCode__c;
                v.XC_ContractType__c = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_ContractType__c;
                v.XC_CostCenter__c  = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_CostCenter__c;
                v.XC_EndDate__c  = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_EndDate__c;
                v.XC_Family__c = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_Family__c;
                v.XC_GenerateMultipleVoucher__c  = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_GenerateMultipleVoucher__c;
                v.XC_HasBeenProcessedForDeactivation__c  = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_HasBeenProcessedForDeactivation__c;
                v.XC_InvoiceDescription__c = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_InvoiceDescription__c;
                v.XC_LegalEntity__c  = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_LegalEntity__c;
                v.XC_NumberOfQuotas__c = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_NumberOfQuotas__c;
                v.XC_Order__c  = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_Order__c;
                v.XC_Product__c  = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_Product__c;
                v.XC_ProductCategory__c  = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_ProductCategory__c;
                v.XC_ProductLine__c = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_ProductLine__c;
                v.XC_ProductService__c  = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_ProductService__c;
                v.XC_PurseExpirationDate__c  = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_PurseExpirationDate__c;
                v.XC_PurseExpirationMonths__c = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_PurseExpirationMonths__c;
                v.XC_SalesChannel__c = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_SalesChannel__c;
                v.XC_StartDate__c = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_StartDate__c;
                v.XC_Status__c = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_Status__c;
                v.XC_Territories__c  = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_Territories__c;
                v.XC_Territory__c  = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_Territory__c;
                v.XC_Type_of_Discount__c  = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_Type_of_Discount__c;
                v.XC_Unlimited__c  = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_Unlimited__c;
                v.XC_Uses__c  = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_Uses__c;
                v.XC_VoucherLifetime__c = mapCamp.get(newCampM.campaignId).XC_Voucher__r.XC_VoucherLifetime__c;

                voucChild.add(v);
                }
            } 

        if (!voucChild.isEmpty()){  
            List<XC_UTIL_Sobject.WrapperResult> res = XC_UTIL_Sobject.insertListRecords(voucChild);  
            
            for(CampaignMember newCampM : listNew) {
                for(XC_Voucher__c child : voucChild){
                    if( mapCamp.get(newCampM.campaignId).XC_Voucher__c == child.XC_ParentVoucher__c){
                        newCampM.XC_Voucher__c = child.id;
                        voucChild.remove(voucChild.indexOf(child));
                        break;
                    }    
                }     
            }
        } 
    }

    public static void updateCode(List<CampaignMember> listNew){ 

        List<String> campMId = new List<String>();
        for(CampaignMember newCampM : listNew) {
            campMId.add(newCampM.Id);} 

        Map<id,CampaignMember> mapCampM = new Map<id,CampaignMember>([
            SELECT XC_Voucher__r.XC_RecordTypeName__c, XC_Voucher__r.XC_VoucherCode__c
            FROM CampaignMember
            WHERE id in: campMId]);

        for(CampaignMember campM : mapCampM.values()){
            if(campM.XC_Voucher__r.XC_RecordTypeName__c == 'Campaign Individual Voucher'){
                campM.XC_VoucherCode__c = campM.XC_Voucher__r.XC_VoucherCode__c;
            }
        }
        List<XC_UTIL_Sobject.WrapperResult> res = XC_UTIL_Sobject.updateListRecords(mapCampM.values());
    }

    /**
    * Delete individual vouchers child
    * @description Delete individual vouchers child related to the deleated campaign members
    * @param listNew the list new
    */
    public static void deleteRelatedVoucher(List<CampaignMember> listNew){

        List<String> voucToDelete = new List<String>();
        for(CampaignMember delCampM : listNew) {
            voucToDelete.add(delCampM.XC_Voucher__c);
            }
        System.debug(voucToDelete);
        Map<id, XC_Voucher__c> mapDel = new Map<id, XC_Voucher__c>([
            SELECT id
            FROM XC_Voucher__c
            WHERE id in: voucToDelete]);
        System.debug(mapDel);

        List<XC_UTIL_Sobject.WrapperResult> res = XC_UTIL_Sobject.deleteListRecords(mapDel.values());
    }
    
    /**
    * Handle Error
    * @description 
    * @param listNew the list new
    */
    public class DmlException extends Exception {}
	


}
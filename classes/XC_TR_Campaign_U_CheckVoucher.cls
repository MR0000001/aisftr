/*
 * The Class XC_TR_Campaign_U_CheckVoucher.
 * @author Simone Trenta - strenta@deloitte.it , Giuseppe Di Bonito - gdibonito@deloitte.it
 * @date Creation 05/08/2019
 * @date Modification 23/08/2019 Giuseppe Di Bonito - gdibonito@deloitte.it
 * @description XC_TR_Campaign_U_CheckVoucher 
 */
public with sharing class XC_TR_Campaign_U_CheckVoucher {

    /**
     * Check on the voucher insert.
     * @description check that the XC_Code__c (inserted on a new Campaign) is present in the available codes and is not already used on another campaign 
     * @param listNew the list new
     */
    public static void checkVoucherOnInsert(List<Campaign> listNew){
        list<String> codeList = new List<String>();
        Map<String,Campaign> voucMap = new Map<String,Campaign>();
 
        for(Campaign newCamp : listNew) {            
            if (!String.isBlank(newCamp.XC_Code__c)){
                codeList.add(newCamp.XC_Code__c);
                voucMap.put(newCamp.XC_Code__c, newCamp);
            } else {
                newCamp.XC_Voucher__c = null;
            }
        } 

        if(codeList.size()==0){
            return;
        }

        Map<Id, XC_Voucher__c> voucQuery = new Map<Id, XC_Voucher__c>([SELECT Id, Name, XC_VoucherCode__c, XC_StartDate__c, XC_EndDate__c, XC_Status__c, RecordType.DeveloperName, XC_ParentVoucher__c,
                                                                       (SELECT id FROM campaigns__r)
                                                                      FROM XC_Voucher__c 
                                                                      WHERE XC_VoucherCode__c in:codeList]);

        Map<String,Id> codeId = new Map<String,Id>();
        for (XC_Voucher__c v : voucQuery.values()) {
            codeId.put(v.XC_VoucherCode__c, v.id);
        }

        for(String newCode : codeList){
            Id voucId = codeId.get(newCode);
            if (voucQuery.get(voucId)==null){
                voucMap.get(newCode).addError('Coupon non presente'); // creare custom label **********

            } else if (voucQuery.get(voucId).campaigns__r.size()>0){
                voucMap.get(newCode).addError('Coupon gia associato a una campagna'); // creare custom label **********
            
            } else if (!((voucQuery.get(voucId).XC_EndDate__c >= System.today()) && (System.today() >= voucQuery.get(voucId).XC_StartDate__c))){
                voucMap.get(newCode).addError('Coupon scaduto o non ancora attivo'); // creare custom label **********

            } else if (voucQuery.get(voucId).XC_Status__c != 'Active'){
                voucMap.get(newCode).addError('Coupon non più attivo'); // creare custom label **********

            } else if (voucQuery.get(voucId).XC_ParentVoucher__c != null){
                voucMap.get(newCode).addError('Il coupon deve essere padre'); // creare custom label **********
         
            } else {
                voucMap.get(newCode).XC_Voucher__c = voucId;
            }
        }  
    }  

    /**
     * Check on the voucher update.
     * @description handle the update of the voucher fields on campaign
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void checkVoucherOnUpdate(List<Campaign> listNew, Map<id, Campaign> mapOld, Map<id, Campaign> mapNew) {
        List<String> fieldToCheck = new List<String>{'XC_Code__c'};

        listNew = XC_UTIL_Sobject.getListChanged(fieldTocheck, mapOld, mapNew);

        for(Campaign newCamp : listNew) {  
            if(newCamp.isActive){
                newCamp.addError('Non puoi cambiare coupon se la campagna è attiva');
            }
        }
        if(!listNew.isEmpty()) {
            checkVoucherOnInsert(listNew);
        }
    }

    /**
     * Update CampaignMembers after Campaign update.
     * @description Update voucher code on CampaignMembers after Campaign update
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void updateChildAfterVoucherUpdate(List<Campaign> listNew, Map<id, Campaign> mapOld, Map<id, Campaign> mapNew) {
        List<String> fieldToCheck = new List<String>{'XC_Code__c'};

        listNew = XC_UTIL_Sobject.getListChanged(fieldTocheck, mapOld, mapNew);
        if(!listNew.isEmpty()) {
            
            List<Id> campIdList = new List<Id>();
            for(Campaign camp : listNew){
                campIdList.add(camp.Id); 
            }

            Map<Id, CampaignMember> voucQuery = new Map<Id, CampaignMember>([SELECT Id, CampaignId, XC_Voucher__c, XC_VoucherCode__c, ContactId, LeadId, XC_Voucher__r.XC_RecordTypeName__c 
                                                                            FROM CampaignMember
                                                                            WHERE CampaignId in:campIdList]);
            
            //This list is used for the operations that we must do only on the campaign members that inherit voucher individual child
            List<CampaignMember> cmList = new List<CampaignMember>();
            for (CampaignMember cm : voucQuery.values()){
                if (cm.XC_Voucher__r.XC_RecordTypeName__c == 'Campaign Individual Voucher'){
                    cmList.add(cm);
                }
            }
            //Update operations
            try {
                XC_TR_CampaignMember_U_CheckVoucher.deleteRelatedVoucher(cmList); //Delete the old Individual Vouchers Child
                XC_TR_CampaignMember_U_CheckVoucher.updateCampaignMemberFields(voucQuery.values()); //
                XC_UTIL_Sobject.updateListRecords(voucQuery.values()); //Update fields on the campaign member
            }
            catch (Exception e) {
                listNew.get(0).addError('Errore! Non ci sono abbastanza voucher.'); //Create custom label
            }
        }
    }
	


}
/*
 * The Class XC_TR_VoucherUtilization_U_changeStatus.
 * @author Simone Trenta - strenta@deloitte.it , Giuseppe Di Bonito - gdibonito@deloitte.it
 * @date Creation 07/08/2019
 * @date Modification dd/mm/yyyy
 * @description XC_TR_VoucherUtilization_U_changeStatus 
 */
public with sharing class XC_TR_VoucherUtilization_U_changeStatus {

    /**
     * Check on the insert.
     * @description 
     * @param listNew the list new
     */
    public static void changeVoucherStatus(List<XC_VoucherUtilization__c> listNew){

        List<String> vocId = new List<String>();

        for(XC_VoucherUtilization__c newVocU : listNew) {
            vocId.add(newVocU.XC_Voucher__c);
        }

        Map<id,XC_Voucher__c> mapVoc = new Map<id,XC_Voucher__c>([
            SELECT id, XC_Uses__c, XC_Usage_Counter__c, RecordType.DeveloperName 	
            FROM XC_Voucher__c
            WHERE id in: vocId]);

        List<XC_Voucher__c> vocList = new List<XC_Voucher__c>();
        for(String newVoc : vocId) {
            System.debug('err: '+mapVoc.get(newVoc).RecordType.DeveloperName);
            System.debug('err: '+mapVoc.get(newVoc).XC_Usage_Counter__c);
            System.debug('err: '+mapVoc.get(newVoc).XC_Uses__c);
            if (((mapVoc.get(newVoc).RecordType.DeveloperName == 'XC_Voucher_General') || (mapVoc.get(newVoc).RecordType.DeveloperName == 'XC_Voucher_Individual')) 
                && (mapVoc.get(newVoc).XC_Usage_Counter__c >= mapVoc.get(newVoc).XC_Uses__c)) {
                mapVoc.get(newVoc).XC_Status__c = 'Burnt';
                vocList.add(mapVoc.get(newVoc));
                System.debug('ok: '+mapVoc.get(newVoc).XC_Status__c);
            }
        } 

        XC_UTIL_Sobject.updateListRecords(vocList);
    }
	

}
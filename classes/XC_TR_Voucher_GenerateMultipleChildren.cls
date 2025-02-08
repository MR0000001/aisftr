/**
 * The Class XC_TR_Voucher_GenerateMultipleChildren.
 *
 * @author Martina Barone - marbarone@deloitte.it & Giulio Serra - giserra@deloitte.it
 * @date Creation 25/10/2018
 * @date Modification dd/mm/yyyy
 * @description  XC_TR_Voucher_GenerateMultipleChildren  – manage
 */

public class XC_TR_Voucher_GenerateMultipleChildren {

    /** The was called. */
    public static Boolean wasCalled = false;
        
    /**
     * @description Avoid recursion.
     *
     * @return the boolean
     */
    public static Boolean avoidRecursion() {

        if(!wasCalled){
            wasCalled = true;
            return false;
        }else{
            return wasCalled;
        }
    }

    /**
     * On multiple voucher insert.
     *
     * @author Martina Barone - marbarone@deloitte.it & Giulio Serra - giserra@deloitte.it
     * @param voucherList the voucher list
     * @date Creation 2/11/2018
     * @date Modification dd/mm/yyyy
     * @description  XC_TR_Voucher_GenerateMultipleChildren  – manage
     */
    public static void onMultipleVoucherInsert(List<XC_Voucher__c> voucherList){ 
        if(avoidRecursion()){
			return;
		}
		 
        List<XC_Voucher__c> toUpdate = new List<XC_Voucher__c>();

        for(XC_Voucher__c voucher : voucherList ){
            if(voucher.XC_Voucher_To_Be_Created__c > 1 && voucher.XC_RecordTypeName__c != 'Campaign Individual Voucher'){
                toUpdate.addAll(XC_UTIL_Voucher.createNvoucherFromSingleVoucher(voucher));
            }
           
        }

        System.debug('to insert' + toUpdate);
        XC_UTIL_Sobject.insertListRecords(toUpdate); 

        wasCalled = avoidRecursion();
    }

     /**
     * On multiple voucher insert.
     *
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it 
     * @param voucherList the voucher list
     * @date Creation 23/08/2019
     * @date Modification dd/mm/yyyy
     * @description  XC_TR_Voucher_GenerateMultipleChildren  – update voucher individual child code already created on th campaign member
     */   

    public static void updateCMCode(List<XC_Voucher__c> listNew){
        System.debug('**updatCMCode');

        if(listNew.get(0).XC_RecordTypeName__c == 'Campaign Individual Voucher' && listNew.get(0).XC_ParentVoucher__c!=null){
            System.debug('**Updating the Individual Child Voucher code on the CampaignMember');
            
            List<String> ids = new List<String>();
            for (XC_Voucher__c v : listNew){
                ids.add(v.XC_ParentVoucher__c);
            }

            Map<id, Campaign> cMs = new Map<id, Campaign>([
                SELECT id, XC_Voucher__c, 
                (SELECT Id, ContactId, LeadId, XC_Voucher__c, XC_VoucherCode__c FROM CampaignMembers)
                FROM Campaign
                WHERE XC_Voucher__c in: ids]);

            List<CampaignMember> cMlist = new List<CampaignMember>();
            cMlist.addAll(cMs.values().CampaignMembers);
            System.debug('**cMlist: ' + cMlist);

            for (XC_Voucher__c vouc : listNew) {
                for (CampaignMember c : cMlist){
                    System.debug('**Contact on Voucher: ' + vouc.XC_Contact__c + '| Lead on Voucher: ' + vouc.XC_Lead__c);
                    System.debug('**Contact on CampaignMember: ' + c.ContactId + '| Lead on CampaignMember: ' + c.LeadId);
                    if(vouc.XC_Contact__c == c.ContactId && vouc.XC_Lead__c == c.LeadId){
                        System.debug('**Voucher Code on the voucher: ' + vouc.XC_VoucherCode__c);
                        c.XC_VoucherCode__c = vouc.XC_VoucherCode__c;
                        System.debug('**Voucher Code on the Campaign Member After Update: ' + c.XC_VoucherCode__c);
                        break;
                    }
                }   
            }System.debug( XC_UTIL_Sobject.updateListRecords(cMlist) );
        }
    }

}
/**
* @author Martina Barone - marbarone@deloitte.it & Giulio Serra - giserra@deloitte.it
* @date Creation 25/10/2018
* @date Modification 03/07/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
* @description XC_TR_Voucher_CouponGeneration – generate a unique code for coupon of the voucher
*/

public without sharing class  XC_TR_Voucher_CouponGeneration {

    /**
     * @description Manage insert coupon generation.
     *
     * @param listNew the list new
     */
    public static void manageInsertCouponGeneration(List<XC_Voucher__c> listNew){

        Set<String> voucherCodeSet = XC_UTIL_Voucher.generateCouponCode(listNew.size());
        List<String> voucherCodeList = new List<String>(voucherCodeSet);
        Map<Id,User> mapUser = new Map<Id,User>([Select Id, XC_LegalEntity__c FROM User where id= :UserInfo.getUserId()]);
        User runningUser;
        Boolean userRetrieved = false;
        If(!mapUser.values().isEmpty() ){
            runningUser = mapUser.values()[0];
            userRetrieved = true;
        }
        Integer i = 0;
        for(XC_Voucher__c v : listNew){
            v.XC_VoucherCode__c = voucherCodeList[i];

            if(v.XC_GenerateMultipleVoucher__c && v.Name.isAlpha()) {
                v.XC_Voucher_To_Be_Created__c = 1;
                v.Name = v.Name + '1';
            }

            if(String.isBlank(v.XC_LegalEntity__c) && userRetrieved) {
                v.XC_LegalEntity__c = runningUser.XC_LegalEntity__c;
            }

            i++;
        }
    }
 
}
/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 12-21-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   12-21-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
public without sharing class XC_AMP_LCC013_PartnerLogoView {

    @AuraEnabled
    public static String getLogoUrl(){
        return String.valueOf(XC_AMP_UTIL_ViewConfiguration.getPartnerUserInfo().get('logoImageUrl'));
    } 
}
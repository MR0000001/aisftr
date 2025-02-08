/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 14/03/2020
* @date Modification dd/mm/yyyy
* @description  – XC_TR_ConfigurationItem_U_StartCongaWF_U  - Util class that for XC_TR_ConfigurationItem_U_StartCongaWF
*/ 
public without sharing class XC_TR_ConfigurationItem_U_StartCongaWF_U {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ConfigurationItem_U_StartCongaWF'); 
    
    /**
    * @description check if the update is triggered by the change of billing profile line item
    * @author salvatore.scarpato@nttdata.com | 14/3/2020 
    * @param NE__OrderItem__c orderItemToCheck 
    * @param Map<Id, NE__OrderItem__c> mapOld 
    * @param Map<Id, NE__OrderItem__c> mapNew 
    **/
    public static Boolean checkBillingProfileLineItemChange(NE__OrderItem__c orderItemToCheck, Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew){
        return checkConditionOnUpdate(orderItemToCheck, mapOld, mapNew);
    }

    /**
    * @description first check that this order item needs Conga document. On insert only.
    * @author salvatore.scarpato@nttdata.com | 20/2/2020 
    * @param NE__OrderItem__c ordIt 
    * @return Boolean 
    **/
    public static Boolean firstCheckOnInsert(NE__OrderItem__c ordIt){
        List<String> subtypeChileanList = new List<String>{'Appliance','Wallbox'};  
        return (ordIt!=null && (String.isBlank(ordIt.NE__Bundle_Configuration__c) &&                              
        ((!String.isEmpty(ordIt.XC_BillingProfileLineItem__c) && ordIt.XC_BPLIStatus__c) || ( (ordIt.XC_PaymentMethod__c == Label.XC_CL_PaymentMethod_NoPaymentRequired || ordIt.XC_PaymentMethod__c == Label.XC_CL_PaymentMethod_CommodityOffer)  && ordIt.XC_StartCongaProcess__c) ) &&
        ((ordIt.XC_Product_Type__c == Label.XC_CL_ProductTypeBundle && ordIt.XC_Product_Subtype__c != Label.XC_CL_Subtype_Photovoltaic && ordIt.XC_Product_Subtype__c != 'Photovoltaic PP' &&  ordIt.XC_LegalEntityFormula__c != Label.XC_CL_EndesaX )  
        || ordIt.XC_Product_Type__c == Label.XC_CL_ProductTypeService
        || (ordIt.XC_Product_Type__c == Label.XC_CL_ProductTypeEquipment && ordIt.XC_Product_Subtype__c == 'LED')
        || (ordIt.XC_Product_Type__c == Label.XC_CL_ProductTypeEquipment && subtypeChileanList.contains(ordIt.XC_Product_Subtype__c) && (ordIt.XC_LegalEntityFormula__c == 'EnelX' || ordIt.XC_LegalEntityFormula__c == 'EnelXMobilityChile' ) )  
        || (ordIt.XC_Product_Type__c == Label.XC_CL_ProductTypeEquipment && ordIt.XC_Product_Subtype__c == 'Appliance' && (ordIt.XC_LegalEntityFormula__c == Label.XC_CL_LegalEntity_Italy || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_Paulo_SP.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_RJ.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_GO.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_CE.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_LUZ_SA_Rio_de_Janeiro_RJ.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_LUZ_SA_Niteroi_RJ.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c)))
        || (ordIt.XC_Product_Type__c == Label.XC_CL_ProductTypeEquipment && ordIt.XC_Product_Subtype__c == 'JuiceAbility' && (ordIt.XC_LegalEntityFormula__c == Label.XC_CL_LegalEntity_Italy || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_Paulo_SP.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_RJ.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_GO.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_CE.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_LUZ_SA_Rio_de_Janeiro_RJ.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_LUZ_SA_Niteroi_RJ.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c)))
        || (ordIt.XC_Product_Type__c == Label.XC_CL_ProductTypeEquipment && ordIt.XC_Product_Subtype__c == Label.XC_CL_ProductSubtypeSmart && String.isBlank(ordIt.NE__Bundle_Configuration__c))
        || FeatureManagement.checkPermission('XC_Brazil_MVP') //DCR 17/01/2022 - MVP Brazil
        || (ordIt.XC_Product_Type__c == Label.XC_CL_ProductTypeEquipment && ordIt.XC_Product_Subtype__c == 'JuiceAbility' && ordIt.XC_LegalEntityFormula__c == 'EnelXMobilityItalia')
        || (ordIt.XC_Product_Type__c == 'Coverage' && ordIt.XC_Product_Subtype__c == 'Maintenance' && String.isEmpty(ordIt.NE__Bundle_Configuration__c) && (ordIt.XC_LegalEntityFormula__c == Label.XC_CL_LegalEntity_Italy || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_Paulo_SP.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_RJ.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_GO.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_CE.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_LUZ_SA_Rio_de_Janeiro_RJ.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_LUZ_SA_Niteroi_RJ.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c)))
        || (ordIt.XC_Product_Type__c == Label.XC_CL_ProductTypeBundle && ordIt.XC_Product_Subtype__c == 'Wallbox' &&  (ordIt.XC_LegalEntityFormula__c == Label.XC_CL_EndesaX || ordIt.XC_LegalEntityFormula__c == 'EnelXMobilitySpain')  ))));                                                                                               
                                                                                                                                                                                
    }


    /**
    * @description method to check the credit assignment available scenario
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com & Domenico Del Prete - domenico.delprete@nttdata.com| 3/4/2020 
    * @param orderItemToCheck 
    * @param mapOld 
    * @param mapNew 
    * @return Boolean 
    **/
    public static Boolean checkCreditAssignmentAvailable(NE__OrderItem__c orderItemToCheck, Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew){
        return (orderItemToCheck.XC_CreditAssignmentAvailable__c == true  &&
            (orderItemToCheck.XC_LegalEntityFormula__c == Label.XC_CL_LegalEntity_Italy || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_Paulo_SP.equalsIgnoreCase(orderItemToCheck.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_RJ.equalsIgnoreCase(orderItemToCheck.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_GO.equalsIgnoreCase(orderItemToCheck.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_CE.equalsIgnoreCase(orderItemToCheck.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_LUZ_SA_Rio_de_Janeiro_RJ.equalsIgnoreCase(orderItemToCheck.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_LUZ_SA_Niteroi_RJ.equalsIgnoreCase(orderItemToCheck.XC_LegalEntityFormula__c)) &&
            !String.isBlank(orderItemToCheck.NE__Bundle_Configuration__c) &&
            orderItemToCheck.XC_Product_Subtype__c == Label.XC_CL_ProductSubtypeIncentive
            && !String.isBlank(orderItemToCheck.XC_CityCode__c)
            && !String.isBlank(orderItemToCheck.XC_Subordinate__c)
            && !String.isBlank(orderItemToCheck.XC_HouseType__c)
            && !String.isBlank(orderItemToCheck.XC_Sheet__c)
            && !String.isBlank(orderItemToCheck.XC_Particle__c)
            && (mapOld.get(orderItemToCheck.Id).XC_CreditAssignmentAvailable__c != mapNew.get(orderItemToCheck.Id).XC_CreditAssignmentAvailable__c
                ||  mapOld.get(orderItemToCheck.Id).XC_CityCode__c != mapNew.get(orderItemToCheck.Id).XC_CityCode__c
                ||  mapOld.get(orderItemToCheck.Id).XC_Subordinate__c != mapNew.get(orderItemToCheck.Id).XC_Subordinate__c
                ||  mapOld.get(orderItemToCheck.Id).XC_HouseType__c != mapNew.get(orderItemToCheck.Id).XC_HouseType__c
                ||  mapOld.get(orderItemToCheck.Id).XC_Sheet__c != mapNew.get(orderItemToCheck.Id).XC_Sheet__c
                ||  mapOld.get(orderItemToCheck.Id).XC_Particle__c != mapNew.get(orderItemToCheck.Id).XC_Particle__c));
    }


    /**
    * @description check if, on insert, the document related to credit assignment has to be created
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 3/4/2020 
    * @param ordIt 
    * @return Boolean 
    **/
    public static Boolean secondCheckOnInsert(NE__OrderItem__c ordIt){
        return (!String.isBlank(ordIt.NE__Bundle_Configuration__c) 
                && ordIt.XC_CreditAssignmentAvailable__c == true
                && ordIt.XC_Product_Subtype__c == Label.XC_CL_ProductSubtypeIncentive
                && (ordIt.XC_LegalEntityFormula__c == Label.XC_CL_LegalEntity_Italy || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_Paulo_SP.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_RJ.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_GO.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_CE.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_LUZ_SA_Rio_de_Janeiro_RJ.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_LUZ_SA_Niteroi_RJ.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c))               
                && !String.isBlank(ordIt.XC_CityCode__c)
                && !String.isBlank(ordIt.XC_Subordinate__c)
                && !String.isBlank(ordIt.XC_HouseType__c)
                && !String.isBlank(ordIt.XC_Sheet__c)
                && !String.isBlank(ordIt.XC_Particle__c));
    }

    /**
    * @description check the scenario in which we need the info of penalty value
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 8/5/2020 
    * @param ordIt 
    * @return Boolean 
    **/
    public static Boolean checkOnBMUpdate(NE__OrderItem__c ordIt,  Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew){
        return checkConditionsOnBMUpdate(ordIt, mapOld ,mapNew);
    }

    /**
    * @description check the condotion on update
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 8/5/2020 
    * @param ordIt 
    * @return Boolean 
    **/
    private static Boolean checkConditionOnUpdate(NE__OrderItem__c orderItemToCheck,  Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew){
        List<String> subtypeChileanList = new List<String>{'Appliance','Wallbox'};  
        NE__OrderItem__c oldOrderItem = mapOld.get(orderItemToCheck.Id);
        NE__OrderItem__c newOrderItem = mapNew.get(orderItemToCheck.Id);
        Boolean checkBillingProfileLineItem = !String.isBlank(orderItemToCheck.XC_BillingProfileLineItem__c) && orderItemToCheck.XC_BPLIStatus__c && (oldOrderItem.XC_BillingProfileLineItem__c != newOrderItem.XC_BillingProfileLineItem__c || (oldOrderItem.XC_StartCongaProcess__c != newOrderItem.XC_StartCongaProcess__c && orderItemToCheck.XC_StartCongaProcess__c) ) ;
        Boolean checkNoPaymentRequired = ( orderItemToCheck.XC_PaymentMethod__c == Label.XC_CL_PaymentMethod_NoPaymentRequired || orderItemToCheck.XC_PaymentMethod__c == Label.XC_CL_PaymentMethod_CommodityOffer) && orderItemToCheck.XC_StartCongaProcess__c && !oldOrderItem.XC_StartCongaProcess__c;
        Boolean checkBundle = orderItemToCheck.XC_Product_Type__c == Label.XC_CL_ProductTypeBundle;
        Boolean checkService = orderItemToCheck.XC_Product_Type__c == Label.XC_CL_ProductTypeService;
        Boolean checkLED = (orderItemToCheck.XC_Product_Type__c == Label.XC_CL_ProductTypeEquipment && orderItemToCheck.XC_Product_Subtype__c == 'LED');
        Boolean checkChileanSubtype = orderItemToCheck.XC_Product_Type__c == Label.XC_CL_ProductTypeEquipment && subtypeChileanList.contains(orderItemToCheck.XC_Product_Subtype__c) && (orderItemToCheck.XC_LegalEntityFormula__c == 'EnelX' || orderItemToCheck.XC_LegalEntityFormula__c == 'EnelXMobilityChile' );  
        Boolean checkAppliance = orderItemToCheck.XC_Product_Type__c == Label.XC_CL_ProductTypeEquipment && orderItemToCheck.XC_Product_Subtype__c == 'Appliance' && (orderItemToCheck.XC_LegalEntityFormula__c == Label.XC_CL_LegalEntity_Italy || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_Paulo_SP.equalsIgnoreCase(orderItemToCheck.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_RJ.equalsIgnoreCase(orderItemToCheck.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_GO.equalsIgnoreCase(orderItemToCheck.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_CE.equalsIgnoreCase(orderItemToCheck.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_LUZ_SA_Rio_de_Janeiro_RJ.equalsIgnoreCase(orderItemToCheck.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_LUZ_SA_Niteroi_RJ.equalsIgnoreCase(orderItemToCheck.XC_LegalEntityFormula__c));
        Boolean checkJuiceAbility = orderItemToCheck.XC_Product_Type__c == Label.XC_CL_ProductTypeEquipment && orderItemToCheck.XC_Product_Subtype__c == 'JuiceAbility' && (orderItemToCheck.XC_LegalEntityFormula__c == Label.XC_CL_LegalEntity_Italy || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_Paulo_SP.equalsIgnoreCase(orderItemToCheck.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_RJ.equalsIgnoreCase(orderItemToCheck.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_GO.equalsIgnoreCase(orderItemToCheck.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_CE.equalsIgnoreCase(orderItemToCheck.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_LUZ_SA_Rio_de_Janeiro_RJ.equalsIgnoreCase(orderItemToCheck.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_LUZ_SA_Niteroi_RJ.equalsIgnoreCase(orderItemToCheck.XC_LegalEntityFormula__c));
        Boolean checkSmart = orderItemToCheck.XC_Product_Type__c == Label.XC_CL_ProductTypeEquipment && orderItemToCheck.XC_Product_Subtype__c == Label.XC_CL_ProductSubtypeSmart && String.isBlank(orderItemToCheck.NE__Bundle_Configuration__c);
        Boolean checkCoverage = orderItemToCheck.XC_Product_Type__c == 'Coverage' && orderItemToCheck.XC_Product_Subtype__c == 'Maintenance' && String.isEmpty(orderItemToCheck.NE__Bundle_Configuration__c) && (orderItemToCheck.XC_LegalEntityFormula__c == Label.XC_CL_LegalEntity_Italy || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_Paulo_SP.equalsIgnoreCase(orderItemToCheck.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_RJ.equalsIgnoreCase(orderItemToCheck.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_GO.equalsIgnoreCase(orderItemToCheck.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_CE.equalsIgnoreCase(orderItemToCheck.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_LUZ_SA_Rio_de_Janeiro_RJ.equalsIgnoreCase(orderItemToCheck.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_LUZ_SA_Niteroi_RJ.equalsIgnoreCase(orderItemToCheck.XC_LegalEntityFormula__c));
        Boolean checkJuiceAbilityMobility = orderItemToCheck.XC_Product_Type__c == Label.XC_CL_ProductTypeEquipment && orderItemToCheck.XC_Product_Subtype__c == 'JuiceAbility' && orderItemToCheck.XC_LegalEntityFormula__c == 'EnelXMobilityItalia';
        return ( 
            ( checkBillingProfileLineItem ||  checkNoPaymentRequired) 
            && (checkBundle|| checkService || checkLED || checkChileanSubtype || checkAppliance || checkJuiceAbility || checkSmart || checkCoverage || checkJuiceAbilityMobility)  
            );
    }


    private static Boolean checkConditionsOnBMUpdate(NE__OrderItem__c ordIt,  Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew){
        List<String> subtypeChileanList = new List<String>{'Appliance','Wallbox'};
        Boolean checkBillingProfileLineItem = !String.isEmpty(ordIt.XC_BillingProfileLineItem__c)  && ordIt.XC_BPLIStatus__c;
        Boolean checkBillingModelChanged = mapOld.get(ordIt.Id).XC_BillingModel__c != mapNew.get(ordIt.Id).XC_BillingModel__c;
        Boolean checkBundle = ordIt.XC_Product_Type__c == Label.XC_CL_ProductTypeBundle;
        Boolean checkEquipmentSmart = ordIt.XC_Product_Type__c == Label.XC_CL_ProductTypeEquipment && ordIt.XC_Product_Subtype__c == Label.XC_CL_ProductSubtypeSmart;
        Boolean legalEntityEndesaX = (ordIt.XC_LegalEntityFormula__c == Label.XC_CL_EndesaX || ordIt.XC_LegalEntityFormula__c == 'EnelXMobilitySpain' );
        Boolean checkPhotovoltaicItaly = ordIt.XC_Product_Type__c == Label.XC_CL_ProductTypeBundle &&( ordIt.XC_Product_Subtype__c == Label.XC_CL_Subtype_Photovoltaic || ordIt.XC_Product_Subtype__c == 'Photovoltaic PP' );
        Boolean legalEntityEnelXItalia = ordIt.XC_LegalEntityFormula__c == Label.XC_CL_LegalEntity_Italy || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_Paulo_SP.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_RJ.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_GO.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_EXBRA_SA_CE.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_LUZ_SA_Rio_de_Janeiro_RJ.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c) || Label.XC_CL_LegalEntity_Brazil_LUZ_SA_Niteroi_RJ.equalsIgnoreCase(ordIt.XC_LegalEntityFormula__c);
        Boolean checkNotInBundle = String.isEmpty(ordIt.NE__Bundle_Configuration__c);
        Boolean checkChileanSubtype = subtypeChileanList.contains(ordIt.XC_Product_Subtype__c);
        Boolean checkLegalEntityEnelX = (ordIt.XC_LegalEntityFormula__c == 'EnelX' || ordIt.XC_LegalEntityFormula__c == 'EnelXMobilityChile' );
        return checkBillingProfileLineItem && checkBillingModelChanged &&
        ( ( (checkBundle || checkEquipmentSmart ) && legalEntityEndesaX )  || (  checkPhotovoltaicItaly && legalEntityEnelXItalia ) || (checkNotInBundle && checkChileanSubtype && checkLegalEntityEnelX) || ( checkPhotovoltaicItaly && checkLegalEntityEnelX ) );
    }
}
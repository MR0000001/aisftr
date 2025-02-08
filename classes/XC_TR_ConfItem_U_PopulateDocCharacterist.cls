/**
* @author : Domenico Del Prete - domenico.delprete@nttdata.com
* @date Creation 13/03/2020
* @date Modification: Salvatore Scarpato 04/09/2020
* @description – XC_TR_ConfItem_U_PopulateDocCharacterist
*/
public without sharing class XC_TR_ConfItem_U_PopulateDocCharacterist {


    /**
    * @description 
    * @author Del Prete Domenico | 13/3/2020 
    * @param listNew
    **/
    public static void populateDocCharacterist(List<NE__OrderItem__c> listNew, Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew){
        List<String> fieldList = new List<String>{'NE__Bundle_Configuration__c'};       
        List<NE__OrderItem__c> confItemListChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        List<NE__OrderItem__c> listOfOiFiltered = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c oi : confItemListChanged){
            if(Label.XC_CL_ProductTypeEquipment == oi.XC_Product_Type__c && Label.XC_CL_AirConditioning == oi.XC_Product_Subtype__c && 
                (Label.XC_CL_LegalEntity_EnelXMobilitySpain == oi.XC_LegalEntityFormula__c || Label.XC_CL_EndesaX == oi.XC_LegalEntityFormula__c || Label.XC_CL_LegalEntity_EnelXMobilityUK == oi.XC_LegalEntityFormula__c || Label.XC_CL_JuicenetLimited == oi.XC_LegalEntityFormula__c)){
                listOfOiFiltered.add(oi);
            }
        }
        if(listOfOiFiltered.isEmpty()){ 
            return;
        }
        Set<Id> listOfProdId = new Set<Id>();
        Map<String, String> mapOiFatherProdId = new Map<String, String>();
        for(NE__OrderItem__c oi : listOfOiFiltered){
            listOfProdId.add(oi.NE__ProdId__c);
            if(!mapOiFatherProdId.containsKey(oi.NE__Bundle_Configuration__c)){
                mapOiFatherProdId.put(oi.NE__Bundle_Configuration__c, oi.NE__ProdId__c);
            }
        }
        List<NE__DocumentationCharacterist__c> listOfDocChar = new List<NE__DocumentationCharacterist__c>([SELECT NE__Product__c, NE__Value__c, Name
                                                                                FROM NE__DocumentationCharacterist__c 
                                                                                WHERE NE__Product__c =: listOfProdId 
                                                                                AND (Name =: 'Subtipo de Producto' OR Name =: 'Potencia (kW)')]);   
        if(listOfDocChar.isEmpty()){
            return;
        }
        Map<String, String> mapValueCripted = calculateValue(listOfDocChar);
        List<NE__OrderItem__c> listOfOiToUpdate = new List<NE__OrderItem__c>();
        for(NE__DocumentationCharacterist__c doc : listOfDocChar){
            for(NE__OrderItem__c oi : listOfOiFiltered){
                NE__OrderItem__c oiFather = new NE__OrderItem__c(Id = oi.NE__Bundle_Configuration__c);
                if(mapOiFatherProdId.get(oi.NE__Bundle_Configuration__c).equals(doc.NE__Product__c)){
                    if(doc.Name == 'Subtipo de Producto'){
                        if(!listOfOiToUpdate.contains(oiFather)){
                            oiFather.XC_DocumentationCharacteristicValue__c = mapValueCripted.get(doc.NE__Value__c);
                        }
                    } if (doc.Name == 'Potencia (kW)'){
                        oiFather = new NE__OrderItem__c(Id = oi.NE__Bundle_Configuration__c);
                        String value =  doc.NE__Value__c;
                        /*if(value.contains('kW')){
                            value = value.remove('kW');
                        }*/
                        if(!listOfOiToUpdate.contains(oiFather)){
                            oiFather.XC_ProductPower__c = value;    
                        }
                    }
                    if(!listOfOiToUpdate.contains(oiFather)){
                        listOfOiToUpdate.add(oiFather);
                    }
                }
            }
        }
        if(!listOfOiToUpdate.isEmpty()){
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_UTIL_Sobject.updateListRecords(listOfOiToUpdate);
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        }
    }

    private static Map<String, String> calculateValue(List<NE__DocumentationCharacterist__c> listOfDocChar){
        Map<String, String> mapValueCripted = new Map<String, String>();
        for(NE__DocumentationCharacterist__c doc : listOfDocChar){
            String docValue = doc.NE__Value__c.toLowerCase();
            if(docValue.contains('multisplit')){
                mapValueCripted.put(doc.NE__Value__c, 'SPX');
            }else if(docValue.contains('split')){
                mapValueCripted.put(doc.NE__Value__c, 'SPL');
            }else if(docValue.contains('casset')){
                mapValueCripted.put(doc.NE__Value__c, 'CAS');
            }else if(docValue.contains('conductos')){
                mapValueCripted.put(doc.NE__Value__c, 'CON');
            }
        }
        return mapValueCripted;
    }
}
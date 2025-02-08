/**
* @author Anna Maria Rosanova annamaria.rosanova@nttdata.com
* @date Creation 25/07/2019
* @date Modification dd/mm/yyyy
* @description  – XC_TR_WorkOrder_U_StartCongaWorkflow_U  - Util class for Start Conga Workflow
*/ 
public without sharing class XC_TR_WorkOrder_U_StartCongaWorkflow_U {
    /**
    * @description Util Wrapper
    */
    public class UtilWrapper{
      public String workType = '';
      public String assetProductName = '';
      public String state = '';
      public Map<String, APXTConga4__Conga_Template__c> templateMap = new Map<String, APXTConga4__Conga_Template__c>();
    }

    static final String SICAL = 'Soluciones Caldera';
    static final String SIAC = 'Soluciones Aire Acondicionado';
    static final String SIRVE = 'Soluciones Recarga Vehículo Eléctrico';  
    static final String SITER = 'Soluciones Termo Eléctrico';
    static final String SICLT = 'Soluciones Solar Fotovoltaica';
    static final String SISTE = 'Soluciones Solar Térmica';
    static final String OKGAS = 'OK Gas';
    static final String OKGASCALENTADOR ='OK Gas Calentador';
    static final String OKGASMINICONCALENTADOR ='OK Gas mini con calefaccion';
    static final String OKGASBASIC ='OK Gas Basic';
    static final String OKGASMINISIN = 'OKGAS MINI SIN';
    static final String OKLUZ = 'OK Luz';
    static final String OKLUZASSIST = 'OK Luz Assist';
    static final String OKLUZBASIC = 'OKLuz Basic';
    static final String OKLUZCONFORT = 'OKLuz Confort';
    static final String OKLUZNEGOCIOS = 'OKLuz Negocios';
    static final String OKLUZNEGOCIOSASSIST = 'OKLuz Negocios Assist';
    static final String AIRCONDITIONING = Label.XC_CL_AirConditioning;
    static final String BOILER = Label.XC_CL_Boiler;

    /**
    * @description Method to get Template Name base on workType
    * @author Anna Maria Rosanova annamaria.rosanova@nttdata.com | 25/07/2019
    * @param  wrapper - UtilWrapper
    * @return templateName String 
    */
     public static String getTemplateId(UtilWrapper wrapper){
        String templateName = '';
        String foundedTemplate = '';
        /*In the report creation , it must be considered the exception in the region of Aragon for Gas Maintenance whose report is the following... Below the detail for the Aragon region
                	Region: Aragon
                    	Provinces:  Huesca 
                                    Zaragoza
                                    Teruel
        */
        if(checkState(wrapper.workType, wrapper.state)){
            templateName = getTemplateNamePlannedMaintenanceAragon(wrapper.assetProductName, templateName);
        }else if(wrapper.workType == Label.XC_CL_WorkType_PlannedMaintenance || wrapper.workType == Label.XC_CL_WorkType_Diagnostic) {
            templateName = getTemplateNamePlannedMaintenance(wrapper.assetProductName, templateName);
        }else if(wrapper.workType == Label.XC_CL_WorkType_Repair){
            templateName = getTemplateNameRepair(wrapper.assetProductName, templateName);
        }else if(wrapper.workType == Label.XC_CL_WorkType_DeliveryInstallation){ 
            templateName = getTemplateNameInstallation(wrapper.assetProductName, templateName);
        }
        
        if(!String.isBlank(templateName) && wrapper.templateMap.containsKey(templateName)){
            foundedTemplate = wrapper.templateMap.get(templateName).Id;
        }
        return foundedTemplate;
        
    }
    
    private static Boolean checkState(String workType, String state){
        system.debug('state => '+ state);
        return (workType== Label.XC_CL_WorkTypeLabel_PlannedMaintenance && (state== 'Huesca' || state == 'Zaragoza' || state == 'Teruel'));
    }


    /**
    * @description Method to get Template Name base on assetProductName for state of Aragon
    * @author Anna Maria Rosanova annamaria.rosanova@nttdata.com | 25/07/2019
    * @param assetProductName String
    * @param templateName String
    * @return templateName String 
    */
    public static String getTemplateNamePlannedMaintenanceAragon(String assetProductName,String templateName){
        if(assetProductName == OKGAS) {
            templateName = 'C0030 Mantenimiento Gas';
        }
        return templateName;
        
    }

    /**
    * @description Method to get Template Name base on assetProductName for Maintenance
    * @author Anna Maria Rosanova annamaria.rosanova@nttdata.com | 25/07/2019
    * @param assetProductName String
    * @param templateName String
    * @return templateName String 
    */
    public static String getTemplateNamePlannedMaintenance(String assetProductName,String templateName){
        if(assetProductName == OKGASMINISIN){
            templateName = 'Mantenimiento OKGAS MINI SIN';
        } else if(assetProductName == OKGAS || assetProductName == OKGASCALENTADOR || 
                assetProductName == OKGASBASIC || assetProductName == OKGASMINICONCALENTADOR) {
            templateName = 'Mantenimiento OKGAS';
        } else if(assetProductName == OKLUZ || assetProductName == OKLUZASSIST || 
                assetProductName == OKLUZCONFORT || assetProductName == OKLUZNEGOCIOS ||
                assetProductName == OKLUZNEGOCIOSASSIST)  {
            templateName = 'Mantenimiento OKLUZ';
        } else if(assetProductName == OKLUZBASIC){
            templateName = 'Mantenimiento OKLUZ Basic';
        } else if(assetProductName == SIAC || assetProductName == 'SIAC') {
            templateName = 'Mantenimiento SIAC';
        }else if(assetProductName == SICAL || assetProductName == 'SICAL') {
            templateName = 'Mantenimiento SICAL';
        }
        return templateName;
    }

    /**
    * @description Method to get Template Name base on assetProductName for repair
    * @author Anna Maria Rosanova annamaria.rosanova@nttdata.com | 25/07/2019
    * @param assetProductName String
    * @param templateName String
    * @return templateName String 
    */
    public static String getTemplateNameRepair(String assetProductName,String templateName){
        if(assetProductName == OKGAS || assetProductName == OKGASCALENTADOR || 
            assetProductName == OKGASBASIC || assetProductName == OKGASMINICONCALENTADOR) {
            templateName = 'Reparación OKGAS';
        } else if(assetProductName == OKLUZ || assetProductName == OKLUZBASIC || 
                assetProductName == OKLUZASSIST || assetProductName == OKLUZNEGOCIOS ||
                assetProductName == OKLUZNEGOCIOSASSIST) {
            templateName = 'Reparación OKLUZ';
        }else if(assetProductName == AIRCONDITIONING) {
            templateName = 'Reparación SIAC';
        }else if(assetProductName == BOILER) {
            templateName = 'Reparación SICAL';
        }
        return templateName;
    }

    /**
    * @description Method to get Template Name base on assetProductName for Installation
    * @author Anna Maria Rosanova annamaria.rosanova@nttdata.com | 25/07/2019
    * @param assetProductName String
    * @param templateName String
    * @return templateName String 
    */
    public static String getTemplateNameInstallation(String assetProductName,String templateName){
        if(assetProductName == SICAL || assetProductName == 'SICAL'){
            templateName = 'Instalación SICAL';
        } else if(assetProductName == SIAC || assetProductName == 'SIAC' || assetProductName == SIRVE || assetProductName == 'SIRVE' || assetProductName == SITER || assetProductName == 'SITER'  || assetProductName == SICLT || assetProductName == 'SICLT'|| assetProductName == SISTE || assetProductName == 'SISTE'){
            templateName = 'Instalación SIAC';
        }
        return templateName; 
    } 

    /**
    * @description getCongaQuery
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 24/10/2019 
    * @param congaQueryName 
    * @param congaQuery 
    * @param queryId 
    * @return String 
    **/
    public static String getCongaQuery(String congaQueryName, String congaQuery, String queryId){
        if(congaQueryName == 'QueryOnAccountByWorkOrder'){
            congaQuery = congaQuery + '[queryACTAAcc]'+queryId + ',';
        }
        if(congaQueryName == 'QueryOnWorkOrderLineItem'){
            congaQuery = congaQuery + '[queryOnWOLI]'+queryId + ',';
        }
        if(congaQueryName == 'QueryOnWorkOrderLineItemMedicion'){
            congaQuery = congaQuery + '[queryOnWOLIMed]'+queryId + ',';
        }
        if(congaQueryName == 'QueryOnServiceAByWorkOrder'){
            congaQuery = congaQuery + '[querySA]'+queryId + ',';
        }
        if(congaQueryName == 'QueryOnAssignedPartnerByWorkOrder'){
            congaQuery = congaQuery + '[queryAssignPARTNER]'+queryId + ',';
        }
        if(congaQueryName == 'QueryOnAssignedResourceByWorkOrder'){
            congaQuery = congaQuery + '[queryAssignedResourc]'+queryId + ',';
        }
        
        congaQuery = getCongaQuerySecondSet(congaQueryName, congaQuery, queryId);
        return congaQuery;
    }

    /**
    * @description getCongaQuerySecondSet
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 24/10/2019 
    * @param congaQueryName 
    * @param congaQuery 
    * @param queryId 
    * @return String
    **/
    public static String getCongaQuerySecondSet(String congaQueryName, String congaQuery, String queryId){
        if(congaQueryName == 'QueryOnDictamen'){
            congaQuery = congaQuery + '[queryDictamen]'+queryId + ',';
        }
        if(congaQueryName == 'QueryOnOrderByWO'){
            congaQuery = congaQuery + '[queryOrder]'+queryId + ',';
        }
		if(congaQueryName == 'QueryOnConfItemByWO'){
            congaQuery = congaQuery + '[queryConfigItem]'+queryId + ',';
        }
        if(congaQueryName == 'QueryOnConfItemByWO1'){
            congaQuery = congaQuery + '[QueryOnConfItemByWO1]'+queryId + ',';
        }
        if(congaQueryName == 'QueryOnConfItemByWO2'){
            congaQuery = congaQuery + '[QueryOnConfItemByWO2]'+queryId + ',';
        }
		if(congaQueryName == 'QueryForEquipamiento'){
            congaQuery = congaQuery + '[QueryForEquipamiento]'+queryId + ',';
        }
		if(congaQueryName == 'QueryForDatosDeLaSolicitud'){
            congaQuery = congaQuery + '[QueryForDS]'+queryId + ',';
        }
		if(congaQueryName == 'QueryOnAddressByWorkOrder'){
            congaQuery = congaQuery + '[QueryOnAddress]'+queryId + ',';
        }
        if(congaQueryName == 'QueryOnAssetByWo'){
            congaQuery = congaQuery + '[QueryOnAssetByWo]'+queryId + ','; 
        } 
        return congaQuery;
    }
}
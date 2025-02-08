/**
* @author Marco Rosa - marco.rosa@nttdata.com
* @date Creation 29/04/2019
* @description XC_DF_Lead – Data Factory for Lead
*/

@isTest
public class XC_DF_Lead {

     /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com && Federica Tavera - federica.tavera@nttdata.com
     * @description Method to create Residential Lead
     * @param n - number of lead
     * @return  List<Lead> to insert
    */

    public static List<Lead> createResidentialLeads(Integer n){
        List<Lead> listLead = new List<Lead>();
        for (Integer i=0; i<n; i++){
            Lead leadToInsert = new Lead();
            leadToInsert.FirstName = 'Pablo';
            leadToInsert.LastName = 'Diaz';
            leadToInsert.RecordTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Residential').getRecordTypeId();
            leadToInsert.Email = 'pablo.residential'+ i +'@gmuil.com';
            leadToInsert.XC_Channel__c = Label.XC_CL_WEB;
            leadToInsert.XC_LeadSource__c  = 'BLOG';
            leadToInsert.Company = 'Diaz';            
            listLead.add(leadToInsert);
        }
        return listLead;
    }

     /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com && Federica Tavera - federica.tavera@nttdata.com
     * @description Method to create Soho Lead
     * @param n - number of lead
     * @return  List<Lead> to insert
    */
    
    public static List<Lead> createSohoLeads(Integer n){
        List<Lead> listLead = new List<Lead>();
        for (Integer i=0; i<n; i++){
            Lead leadToInsert = new Lead();
            leadToInsert.FirstName = 'Pablo';
            leadToInsert.LastName = 'Diaz';
            leadToInsert.RecordTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Soho').getRecordTypeId();
            leadToInsert.Email = 'pablo.Soho'+ i +'@gmuil.com';
            leadToInsert.XC_Channel__c = Label.XC_CL_WEB;
            leadToInsert.XC_LeadSource__c  = 'BLOG';
            leadToInsert.Company = ' ENELX';
            leadToInsert.XC_DocumentCountry__c = 'Spain';
            leadToInsert.XC_DocumentType__c = 'NIF';
            leadToInsert.XC_DocumentNumber__c = '42653268K';
            listLead.add(leadToInsert);
        }
        return listLead;
    }

     /** 
     * @author Roberta Porrega - roberta.porrega@nttdata.com && Federica Tavera - federica.tavera@nttdata.com
     * @description Method to create Condominium Lead
     * @param n - number of lead
     * @return  List<Lead> to insert
    */
    
    public static List<Lead> createCondominiumLeads(Integer n){
        List<Lead> listLead = new List<Lead>();
        for (Integer i=0; i<n; i++){
            Lead leadToInsert = new Lead();
            leadToInsert.FirstName = 'Pablo';
            leadToInsert.LastName = 'Diaz';
            leadToInsert.RecordTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Condominium').getRecordTypeId();
            leadToInsert.Email = 'pablo.condominuim'+ i +'@gmuil.com';
            leadToInsert.XC_Channel__c = 'Web';
            leadToInsert.XC_LeadSource__c  = 'BLOG';
            leadToInsert.XC_CondominiumName__c = 'ENELX';
            leadToInsert.XC_DocumentCountry__c = 'Spain';
            leadToInsert.XC_DocumentType__c = 'NIF';
            leadToInsert.XC_DocumentNumber__c = '21140677C';
            leadToInsert.Company = 'Company Test';
            listLead.add(leadToInsert);
        }
        return listLead;
    }
    
    /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com && Federica Tavera - federica.tavera@nttdata.com
     * @description Method to create One Residential Lead
     * @return Lead to insert
    */
    public static Lead createResidentialLead() {
        List<Lead> leadToCreate = createResidentialLeads(1);
        return leadToCreate[0];
    }

    /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com && Federica Tavera - federica.tavera@nttdata.com
     * @description Method to create One Condominium Lead
     * @return Lead to insert
    */
    public static Lead createCondominiumLead() {
        List<Lead> leadToCreate = createCondominiumLeads(1);
        return leadToCreate[0];
    }

    /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com && Federica Tavera - federica.tavera@nttdata.com
     * @description Method to create One Soho Lead
     * @return Lead to insert
    */
    public static Lead createSohoLead() {  
        List<Lead> leadToCreate = createSohoLeads(1);
        return leadToCreate[0];
    }
      /**
     * @author Lorenzo Orlanducci
     * @description Method to create Lead with all address fields populated
     * @param n - number of lead
     * @return  List<Lead> to insert
    */

    public static List<Lead> createResidentialLeadsWithAddress(Integer n){
        List<Lead> listLead = new List<Lead>();
        for (Integer i=0; i<n; i++){
            Lead leadToInsert = new Lead();
            leadToInsert.FirstName = 'Pablo';
            leadToInsert.XC_Address__c = 'Roma';
            leadToInsert.XC_StreetType__c ='Via';
            leadToInsert.XC_StreetNumber__c='3';
            leadToInsert.XC_City__c='Madrid';
            leadToInsert.XC_ZipCode__c='28080';
            leadToInsert.XC_Municipality__c='Madrid';
            leadToInsert.XC_Country__c='Spain';
            leadToInsert.XC_Province__c='Madrid';
            leadToInsert.LastName = 'Diaz';
            leadToInsert.RecordTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Residential').getRecordTypeId();
            leadToInsert.Email = 'pablo.residential'+ i +'@gmuil.com';
            leadToInsert.XC_Channel__c = 'Web';
            leadToInsert.XC_LeadSource__c  = 'BLOG';
            leadToInsert.Company = 'Diaz';            
            listLead.add(leadToInsert);
        }
        return listLead;
    }



}
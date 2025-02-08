/**
 * The Class XC_LCC234_RefreshLoadedDocument.
 *
 * @author Simone Trenta - strenta@deloitte.it
 * @date Creation 01/12/2020
 * @date Modification dd/mm/yyyy
 * @description 
 */
public without sharing class XC_LCC234_RefreshLoadedDocument {

    @AuraEnabled
    public static Map<String,String> callDoxee(String objectId){
        Map<String,String> res = new Map<String,String>();

        XC_REST_RefreshLoadedDocument.RequestWrapper wr = new XC_REST_RefreshLoadedDocument.RequestWrapper();
        XC_REST_RefreshLoadedDocument.FileWrapper f = new XC_REST_RefreshLoadedDocument.FileWrapper();
        
        f.object_id = objectId;
        f.object_type = 'CONFIGURATION_ID';
        f.company = 'ENELXITALIA-B2C';
        f.country = 'ITALY'; 

        wr.FileItem = new List<XC_REST_RefreshLoadedDocument.FileWrapper>();
        wr.FileItem.add(f);

        XC_REST_RefreshLoadedDocument.ResponseWrapper response = XC_REST_RefreshLoadedDocument.callToDoxee(wr);

        res.put('Result',response.result.ErrorCode);

        return res;
    }

}
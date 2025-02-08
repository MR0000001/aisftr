/**
* @author: Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date  : 14/12/2018
* @description  The class shares the visibility of document to all users, this is needed for community users that otherwise cannot see documents in that context 
*/
public without sharing class XC_TR_ContentDocumentLink_U_Visibility {

    /**
     * @description sets the visibilty on content document link
     * @param listNew the new visibilty on content document link
     */
    public static void setVisibiltyOnContentDocumentLink(List<ContentDocumentLink> listNew){
        for(ContentDocumentLink document: listNew){
            if(document.Visibility == 'InternalUsers'){
                document.Visibility = 'AllUsers';
            }
        }
    }
}
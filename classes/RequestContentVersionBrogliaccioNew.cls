/**
 * Created by snekkanti002 on 20/09/2021.
 */

public without sharing class RequestContentVersionBrogliaccioNew {
    public List<Allegato> allegati = new List<Allegato>();

    public class Allegato {
        public Integer VerbatelID;
        public String AllegatoID;
        public String FileName;
        public String Titolo;
    }

    public RequestContentVersionBrogliaccioNew(BrogliaccioCaseListWrapperNew brogliaccioCaseListWrapper) {
        for(String cId : brogliaccioCaseListWrapper.caseIdCvsMap.keySet()) {
            for(ContentVersion cv : brogliaccioCaseListWrapper.caseIdCvsMap.get(cId)) {
                Allegato allegato = new Allegato();

                allegato.VerbatelID = Integer.valueOf(brogliaccioCaseListWrapper.caseMap.get(cId).ExternalSystemId_Brogliaccio__c);
                allegato.FileName = cv.Title + '.' + cv.FileExtension;
                allegato.Titolo = cv.Title;
                allegato.AllegatoID = cv.Id;

                this.allegati.add(allegato);
            }
        }
    }
}
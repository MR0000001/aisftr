/**
 * Created by SNEKKANTI00 on 12/07/2021.
 */

public with sharing class RequestBrogliaccioPull {
    public List<StatoSegnalazione> StatoSegnalazione = new List<StatoSegnalazione>();

    public class StatoSegnalazione {
        Public Integer VerbatelID;
    }

    public RequestBrogliaccioPull(Map<String, Case> extBrogliaccioIdCasesMap) {
        for(String extBrogliaccioId : extBrogliaccioIdCasesMap.keySet()) {
            StatoSegnalazione seg = new StatoSegnalazione();

            seg.VerbatelID = Integer.valueOf(extBrogliaccioId);

            this.StatoSegnalazione.add(seg);
        }
    }
}
/**
 * Created by snekkanti002 on 25/05/2022.
 */

public without sharing class RequestIAM {
    public List<Conti> request = new List<Conti>();

    public RequestIAM(List<Account> accounts) {
        for(Account acc : accounts) {
            Conti c = new Conti();

            c.EMAIL = acc.PersonEmail;
            c.TELEFONO_FISSO = acc.PersonHomePhone;
            c.TELEFONO_MOBILE = acc.PersonMobilePhone;
            c.FAX = acc.Fax;
            c.CODICE_FISCALE = acc.Fiscal_Code__pc;

            this.request.add(c);
        }
    }

    public class Conti {
        public String EMAIL;
        public String TELEFONO_FISSO;
        public String TELEFONO_MOBILE;
        public String FAX;
        public String CODICE_FISCALE;
    }
}
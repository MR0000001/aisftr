/**
 * Created by snekkanti002 on 06/10/2021.
 */

public without sharing class ResponseSigeud {
    public String codice_fiscale { get; set; }
    public List<Rappresentate> rappresentate { get; set; }

    public class Rappresentate {
        public List<Cariche> cariche { get; set; }
        public Indirizzo indirizzo { get; set; }
        public CatGiuridica cat_giuridica { get; set; }
        public String codice_fiscale { get; set; }
        public String partita_iva { get; set; }
        public String ragione_sociale { get; set; }
        public String indirizzo_pec { get; set; }
        public String indirizzo_mail { get; set; }
    }

    public class Cariche {
        public String descrizione { get; set; }
        public String codice { get; set; }
        public String data_inizio { get; set; }
        public String data_fine { get; set; }
    }

    public class Indirizzo {
        public String civico { get; set; }
        public String via { get; set; }
        public String cap { get; set; }
        public Comune comune { get; set; }
    }

    public class Comune {
        public String descrizione { get; set; }
        public String sigla_provincia { get; set; }
    }

    public class CatGiuridica {
        public String codice { get; set; }
        public String descrizione { get; set; }
    }
}
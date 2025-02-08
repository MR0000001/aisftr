/**
 * Created by SNEKKANTI00 on 17/12/2020.
 */

public with sharing class ResponseAnagrafica {
    public Persona persona;
    public AnagraficaError anagraficaError;
	public Elenco elenco;
    
	public class Elenco {
		public List<PersonaElenco> personaElenco;
	}

	public class PersonaElenco {
		public String codiceIndividuale;
		public String nome;
		public String cognome;
		public Datadi datadiNascita;
		public String sesso;
		public String indirizzo;
		public String flagVivoResidente;
		public String codiceFiscale;
		public String descrizione;
	}

    public class Persona {
        public DatiAnagrafeRoma datiAnagrafeRoma = new DatiAnagrafeRoma();
        public PersonaCompleta personaCompleta = new PersonaCompleta();
        public Decesso decesso = new Decesso();
        public Documenti documenti = new Documenti();
        public DatiIndirizzo datiIndirizzo = new DatiIndirizzo();
        public Nascita nascita = new Nascita();
        public Matrimonio matrimonio = new Matrimonio();
        public SituazioneAnagrafe situazioneAnagrafe = new SituazioneAnagrafe();
    }

    public class Decesso {
        public Datadi datadiDecesso = new Datadi();
    }

    public class Documenti {
        public CartaIdentita cartaIdentita = new CartaIdentita();
    }

    public class CartaIdentita {
        public String numeroCI;
    }

    public class DatiAnagrafeRoma {
        public DatiIndividuo datiIndividuo = new DatiIndividuo();
        public DatiFamiglia datiFamiglia = new DatiFamiglia();
    }

    public class DatiIndividuo {
        public String codiceIndividuale;
        public TipoIndividuo tipoIndividuo = new TipoIndividuo();
    }

    public class TipoIndividuo {
        public String flagVivoResidente;
        public String vivo;
        public String residente;
    }

    public class DatiFamiglia {
        public String codiceFamiglia;
        public Integer flagPresenzaInFamiglia;
        public String rapportoParentela;
        public Datadi dataInizioAppartenenzaFamiglia = new Datadi();
    }

    public class PersonaCompleta {
        public String sesso;
        public String nome;
        public String cognome;
        public String codiceFiscale;
        public String statoCivile;
        public String titolodiStudio;
        public Datadi datadiNascita = new Datadi();
        public Luogodi luogodiNascita = new Luogodi();
        public Cittadinanza cittadinanza = new Cittadinanza();
    }

    public class Datadi {
        public Integer giorno;
        public Integer mese;
        public Integer anno;
    }

    public class Luogodi {
        public String nomeComune;
        public String siglaProvincia;
        public String siglaStato;
        public String nomeStato;
        public String codiceComuneISTAT;
        public String codiceProvinciaISTAT;
        public Integer codiceStatoISTAT;
    }

    public class Cittadinanza {
        public String descrizioneCittadinanza;
        public Integer codiceStatoISTAT;
    }

    public class DatiIndirizzo {
        public Indirizzo indirizzo = new Indirizzo();
        public Datadi dataInizioValiditaDomicilio = new Datadi();
        public ProtocolloDomicilio protocolloDomicilio = new ProtocolloDomicilio();
    }

    public class Indirizzo {
        public IndirizzoItaliano indirizzoItaliano = new IndirizzoItaliano();
    }

    public class IndirizzoItaliano {
        public String codiceVia;
        public String toponimo;
        public String indirizzoBreve;
        public String scala;
        public String interno;
        public String municipio;
        public String CAP;
        public String lotto;
        public String piano;
        public NumeroCivico numeroCivico = new NumeroCivico();
    }

    public class NumeroCivico {
        public String lettera;
        public Integer numero;
    }

    public class ProtocolloDomicilio {
        public Integer numeroProtocollo;
    }

    public class Nascita {
        public Datadi datadiNascita = new Datadi();
        public Luogodi luogodiNascita = new Luogodi();
        public Attodi attodiNascita = new Attodi();
        public Genitori genitori = new Genitori();
    }

    public class Attodi {
        public String tipoRegistrazione;
        public String numero;
        public Integer parte;
        public String serie;
        public String esponente;
        public String anno;
        public Luogodi comuneRegistrazione = new Luogodi();
    }

    public class Genitori {
        public Genitoro padre = new Genitoro();
        public Genitoro madre = new Genitoro();
    }

    public class Genitoro {
        public String nominativo;
    }

    public class Matrimonio {
        public DatiConiuge datiConiuge = new DatiConiuge();
        public Datadi datadiMatrimonio = new Datadi();
        public Luogodi luogodiMatrimonio = new Luogodi();
        public Attodi attodiMatrimonio =  new Attodi();
    }

    public class DatiConiuge {
        public Coniuge coniuge = new Coniuge();
    }

    public class Coniuge {
        public String codiceIndividuale;
        public String cognome;
        public String nome;
        public String sesso;
    }

    public class SituazioneAnagrafe {
        public Iscrizione iscrizione = new Iscrizione();
        public Datadi datadiIscrizione = new Datadi();
        public Luogodi comunediProvenienza =  new Luogodi();
        public ProtocolloIscrizione protocolloIscrizione = new ProtocolloIscrizione();
    }

    public class Iscrizione {
        public String nomeComune;
        public String nomeStato;
        public Datadi dataDefinizioneImmigrazione = new Datadi();
        public String siglaProvincia;
        public String motivodiIscrizione;
    }

    public class ProtocolloIscrizione {
        public String numeroProtocollo;
        public Integer annoProtocollo;
    }

    public class AnagraficaError {
        private String errorMessage;
        private String errorCode;

        public AnagraficaError(String message, String code) {
            this.errorMessage = message;
            this.errorCode = code;
        }
    }
}
/**
 * Created by SNEKKANTI00 on 12/07/2021.
 */

public without sharing class ResponseGEDCase {
    public ApiWsResponse apiWsResponse;
    public List<ListaNumeroProtollo> listaNumeroProtollo;

    public class ApiWsResponse {
        public String errorCode;
        public String errorMessage;
    }

    public class ListaNumeroProtollo {
        public String id;
        public Integer progressivoProtocollo;
        public String tipoProtocollo;
        public Integer annoProtocollo;
        public Long dataProtocollo;
        public Long oraProtocollo;
        public String codiceMittente;
        public Error error;
    }

    public class Error {
        public String errorCode;
        public String errorMessage;
    }
}
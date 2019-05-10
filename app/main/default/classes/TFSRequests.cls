public class TFSRequests {
        public static HttpResponse fetchWorkItems(String method, String endpoin){
        try {
            HttpRequest req = getfetchRequest( method,endpoin);
            HttpResponse res = sendRequest(req);
            return res;
        } catch(System.CalloutException e) {
            System.debug(e);
            return null;
        }
    }
    public static HttpRequest getfetchRequest(String method, String endpoin){
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setHeader('Content-Type','application/json');
        req.setEndpoint(endpoin);
        system.debug(req.getEndpoint());
        req.setHeader('Authorization', 'Basic OjRkbXJya2VyY3g2N3pnbGdrZTM2cXFmbmxjczZ1YW9xdWtmeTc1YjZnd2NjbWZqNG1vY2E=');
       

        req.setTimeout(100000);
        return req;
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public static HttpResponse searchWorkItems(String method, String endpoin, String body){
        try {
            HttpRequest req = getsearcRequest( method,  endpoin,  body);
            HttpResponse res = sendRequest(req);
            return res;
        } catch(System.CalloutException e) {
            System.debug(e);
            return null;
        }
    }
    public static HttpRequest getsearcRequest(String method, String endpoin, String body){
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setHeader('Content-Type','application/json');
        req.setEndpoint(endpoin);
        system.debug(req.getEndpoint());
        req.setHeader('Authorization', 'Basic OjRkbXJya2VyY3g2N3pnbGdrZTM2cXFmbmxjczZ1YW9xdWtmeTc1YjZnd2NjbWZqNG1vY2E=');
       
        req.setBody(body);
        req.setTimeout(100000);
        return req;
    } 
    
    
    
    
    public static HttpResponse getTFSWorkItems(){
        try {
            HttpRequest req = getRequest();
            HttpResponse res = sendRequest(req);
            return res;
        } catch(System.CalloutException e) {
            System.debug(e);
            return null;
        }
    }
    
    
    
    
    public static HttpResponse createWorkItems(String method, String endpoin, String body){
        try {
            HttpRequest req = getCreateWIRequest( method, endpoin ,  body);
            HttpResponse res = sendRequest(req);
            return res;
        } catch(System.CalloutException e) {
            System.debug(e);
            return null;
        }
    } 
    public static HttpRequest getCreateWIRequest(String method, String endpoin, String body){
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setHeader('Content-Type','application/json-patch+json');
        req.setEndpoint('callout:TFSDemo'+endpoin);
        req.setHeader('Authorization', '{!$Credential.Password}');
       
        req.setBody(body);
        req.setTimeout(100000);
        return req;
    } 
    public static HttpRequest getRequest(){
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept', 'application/json');
        req.setEndpoint('callout:TFSDemo/ibegei/test/_apis/wit/workitemtypes?api-version=5.0');
        req.setHeader('Authorization', '{!$Credential.Password}');
       
        
        req.setTimeout(100000);
        return req;
    }
    
        public static HttpResponse sendRequest(HttpRequest req) {
        Http http = new Http();
        HttpResponse res=http.send(req);
        System.debug('StatusCode______'+res.getStatusCode());
        System.debug('Status__________'+res.getStatus());
        System.debug('Body____________'+res.getBody());
        return res;
    }
    
    public static String authHeader(String u, String p) {
        Blob headerValue = Blob.valueOf(u + ':' + p);
        system.debug(p);
        system.debug('Basic ' + EncodingUtil.base64Encode(headerValue));
        return 'Basic ' + EncodingUtil.base64Encode(headerValue);
    }
    
}
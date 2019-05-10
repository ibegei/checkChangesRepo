public class JIRA_Requests {
    public static HttpResponse  createIssue(String method, String endpoin, String body){
        try {
            system.debug(body);
            HttpRequest req = getCreateIssueRequest( method,endpoin,body);
            HttpResponse res = sendRequest(req);
            return res;
        } catch(System.CalloutException e) {
            System.debug(e);
            return null;
        }    
    }
    public static HttpRequest getCreateIssueRequest(String method, String endpoin,String body){
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setHeader('Content-Type','application/json');
        req.setEndpoint('callout:JIRA_NP_Cloud'+endpoin);
        req.setBody(body);
        req.setTimeout(100000);
        return req;
    }
    public static HttpResponse  getProjects(String method, String endpoin){
        try {
            HttpRequest req = getJiraProjectsRequest( method,endpoin);
            HttpResponse res = sendRequest(req);
            return res;
        } catch(System.CalloutException e) {
            System.debug(e);
            return null;
        }    
    }
    public static HttpRequest getJiraProjectsRequest(String method, String endpoin){
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setHeader('Content-Type','application/json');
        req.setEndpoint('callout:JIRA_NP_Cloud'+endpoin);

        req.setTimeout(100000);
        return req;
    }
    
    public static HttpResponse fetchJiraIssues(String method, String endpoin,String body){
        try {
            HttpRequest req = getfetchRequest( method,endpoin,body);
            HttpResponse res = sendRequest(req);
            return res;
        } catch(System.CalloutException e) {
            System.debug(e);
            return null;
        }
    }
    public static HttpRequest getfetchRequest(String method, String endpoin,String body){
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setHeader('Content-Type','application/json');
        req.setEndpoint('callout:JIRA_NP_Cloud'+endpoin);
        req.setBody(body);
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
}
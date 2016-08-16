public class Communicate 
{
	public HttpResponse SendRequest(string requestURL, string Body)
	{
		HttpRequest req = new HttpRequest();
	    req.setEndpoint(requestURL);
	 	req.setBody(Body);
	    req.setMethod('POST');
	    req.setHeader('content-type', 'text/xml');
		//req.setHeader('Content-Length','1024');
		//req.setHeader('Host','s3.amazonaws.com');
		//req.setHeader('Connection','keep-alive');

	    
	    Http http = new Http();
	    HttpResponse res = http.send(req);
	    return res;
	    	
	}
}
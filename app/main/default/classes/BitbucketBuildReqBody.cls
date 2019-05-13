public class BitbucketBuildReqBody {
    
    public static Blob getAttachmentsBodyasBlob(List<Attachment> attachments , String commitMessage){
        system.debug(attachments);
        Blob bodyBlob = null;
        String boundary = UserInfo.getUserId();
        
        
        String header='';
        header=
            '--' + boundary + '\r\n' +
            'Content-Disposition: form-data; name="message"\r\n\r\n' + 
            commitMessage+'\r\n';
        String bodyEncoded = EncodingUtil.base64Encode(Blob.valueOf(header + '\r\n\r\n'));
        while (bodyEncoded.endsWith('=')){
            header += ' ';
            bodyEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
        
        for(Attachment att:attachments){
            Blob  file_body=att.Body;
            String  file_name=att.Name;
            System.debug(bodyEncoded);
            String row=
                '--' + boundary + '\r\n' +
                'Content-Disposition: form-data; name="app/main/default/'+file_name+'"; filename="' + file_name + '"\r\n' +
                'Content-Type: application/octet-stream'+
                EncodingUtil.base64Encode(file_body);
            bodyEncoded=bodyEncoded+row;
            System.debug(bodyEncoded);
            String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
            
            if (last4Bytes.endsWith('==')) {
                
            } else if (last4Bytes.endsWith('=')) {
                last4Bytes = last4Bytes.substring(0, 3) + 'N';
                bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length()-4) + last4Bytes;
                bodyEncoded = bodyEncoded+'\n';             
            } else {
                bodyEncoded = bodyEncoded+'\r\n';
            }
        }
        
        
        String footer = '--' + boundary + '--';
        
        System.debug(bodyEncoded);
        
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
        
        if (last4Bytes.endsWith('==')) {
            last4Bytes = last4Bytes.substring(0, 2) + '0K';
            bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length() - 4) + last4Bytes;
            
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(bodyEncoded + footerEncoded);
        } else if (last4Bytes.endsWith('=')) {
            last4Bytes = last4Bytes.substring(0, 3) + 'N';
            bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length()-4) + last4Bytes;
            footer = '\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(bodyEncoded + footerEncoded);              
        } else {
            footer = '\r\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(bodyEncoded + footerEncoded);  
        } 
        
        return bodyBlob;
        
    }
    
    public static string getstrBody(List<Attachment> attachments , String commitMessage){

        String boundary = UserInfo.getUserId();
        String body='';
        body=
            '--' + boundary + '\r\n' +
            'Content-Disposition: form-data; name="message"\r\n\r\n' + 
            commitMessage+'\r\n';
        List<String> elementToRemove = new List<String>();
        for(Attachment att:attachments){
            if(att.Name=='destructiveChangesPost.xml'){
                XMLparse parser = new XMLparse(att.Body.toString());
                elementToRemove = parser.Files;
            }
            body+=
                
                '--' + boundary + '\r\n' +
                'Content-Disposition: form-data; name="app/main/default/src/'+att.Name+'"; filename="' + att.Name + '"\r\n' +
                'Content-Type: application/octet-stream \r\n\r\n'+
                att.Body.toString()+'r\n';
        }
        if(!elementToRemove.isEmpty()){
            for(String pathToDel: elementToRemove){
                 body+=
                '--' + boundary + '\r\n' +
                     'Content-Disposition: form-data; name="files"\r\n\r\n'+
                     'app/main/default/src/'+pathToDel+'\r\n';
            } 
        }
        
        body+='--' + boundary + '--';
        system.debug(body);
        return body;
    }
    
}
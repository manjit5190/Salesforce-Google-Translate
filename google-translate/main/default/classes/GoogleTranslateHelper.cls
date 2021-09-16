public with sharing class GoogleTranslateHelper {

    @AuraEnabled
    public static String translate(String input) {
        GoogleTranslateHelper helper = new GoogleTranslateHelper();
        GoogleTranslateWrapper.Details request = (GoogleTranslateWrapper.Details)
                JSON.deserialize(input, GoogleTranslateWrapper.Details.class);
        request.validate();
        String requestUrl = helper.prepareRequestUrl(request);
        HttpResponse response = helper.sendRequest(requestUrl);
        GoogleTranslateWrapper.Details translateResponse = helper.prepareResponse(request, response);
        return JSON.serialize(translateResponse, true);
    }

    private String getApiKey() {
        API_Keys__c apiKeys = API_Keys__c.getInstance();
        String key = apiKeys.GoogleTranslation__c;
        if (String.isBlank(key)) {
            throw new GoogleTranslateException('API key cannot be blank');
        }
        return key;
    }

    private String prepareRequestUrl(GoogleTranslateWrapper.Details request) {
        String baseUrl = 'https://translation.googleapis.com/language/translate/v2';
        String url = '?key={0}&target={1}&source={2}&format={3}&{4}';
        String requestUrl = baseUrl + String.format(url, new List<String>{
                this.getApiKey(), request.fromLanguage, request.toLanguage,
                request.isHTML ? 'html' : 'text', String.join(request.getEncodedResponse(), '&')
        });
        System.debug(requestUrl);
        return requestUrl;
    }

    private HttpResponse sendRequest(String url) {
        HttpRequest request = new HttpRequest();
        request.setTimeout(30000);
        request.setMethod('GET');
        request.setEndpoint(url);
        HttpResponse response = new Http().send(request);
        return response;
    }

    private GoogleTranslateWrapper.Details prepareResponse(GoogleTranslateWrapper.Details input,
            HttpResponse response) {
        if (response.getStatusCode() == 200) {
            GoogleTranslateWrapper.TranslateResponse translateResponse = (GoogleTranslateWrapper.TranslateResponse)
                    JSON.deserialize(response.getBody(), GoogleTranslateWrapper.TranslateResponse.class);
            for (GoogleTranslateWrapper.Translation translation : translateResponse.data.translations) {
                input.translatedText.add(translation.translatedText);
            }
        } else {
            throw new GoogleTranslateException(response.getBody());
        }
        return input;
    }

    public class GoogleTranslateException extends Exception {
    }
}
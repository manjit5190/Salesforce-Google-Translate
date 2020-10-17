/**
 * Created by singh on 10/14/2020.
 */

public with sharing class GoogleTranslateWrapper {
    public class TranslateResponse {
        public Data data;
    }
    public class Data {
        public Translation[] translations;
    }
    public class Translation {
        public String translatedText;
        public String detectedSourceLanguage;
    }

    public class Details {
        public List<String> textToBeTranslated;
        public List<String> translatedText;
        public Boolean isHTML;
        public String toLanguage;
        public String fromLanguage;

        public List<String> getEncodedResponse() {
            List<String> encodedStrings = new List<String>();
            for (String input : textToBeTranslated) {
                encodedStrings.add('q=' + EncodingUtil.urlEncode(input, 'UTF-8'));
            }
            return encodedStrings;
        }

        public void validate() {
            if (isHTML == null) {
                isHTML = false;
            }
            if (this.textToBeTranslated == null || this.textToBeTranslated.isEmpty() || String.isBlank(this.toLanguage)) {
                throw new GoogleTranslateHelper.GoogleTranslateException('Text and to Language must not be blank');
            }
            this.translatedText = new List<String>();
        }
    }
}